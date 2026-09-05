"""Verify MPS numerical correctness against CPU reference.

Background: PyTorch's MPS backend has a history of silently incorrect results
(TransformerLens issue #1178: IOI logit difference flipped sign on MPS).
This script measures whether our stack (torch 2.13, transformer_lens 3.5.1)
is affected, per model and dtype we actually use:

- gpt2 in float32: logits + per-layer residual stream + IOI logit diff (Mary-John)
- gemma-2-2b-it in bfloat16: logits + per-layer residual stream

Run:  uv run python scripts/verify_mps.py
"""

import gc

import torch
from transformer_lens import HookedTransformer

PROMPTS = [
    "The capital of France is",
    "In a shocking finding, scientists discovered that",
    "def fibonacci(n):",
]
IOI_PROMPT = "When John and Mary went to the store, John gave a drink to"


def run_on_device(model_name: str, device: str, dtype: torch.dtype):
    """Forward-pass all prompts, return logits and residual stream per prompt (on CPU, fp32)."""
    model = HookedTransformer.from_pretrained(model_name, device=device, dtype=dtype)
    results = []
    for prompt in PROMPTS + [IOI_PROMPT]:
        logits, cache = model.run_with_cache(
            prompt, names_filter=lambda name: name.endswith("resid_post")
        )
        results.append({
            "final_logits": logits[0, -1].float().cpu(),
            "resid": {k: v.float().cpu() for k, v in cache.items()},
        })

    ioi_diff = None
    if model_name == "gpt2":
        mary, john = model.to_single_token(" Mary"), model.to_single_token(" John")
        ioi_logits = results[-1]["final_logits"]
        ioi_diff = (ioi_logits[mary] - ioi_logits[john]).item()

    del model
    gc.collect()
    if device == "mps":
        torch.mps.empty_cache()
    return results, ioi_diff


def compare(model_name: str, dtype: torch.dtype) -> None:
    print(f"\n=== {model_name} ({dtype}) ===")
    cpu_results, cpu_ioi = run_on_device(model_name, "cpu", dtype)
    mps_results, mps_ioi = run_on_device(model_name, "mps", dtype)

    for prompt, cpu_r, mps_r in zip(PROMPTS + [IOI_PROMPT], cpu_results, mps_results):
        logit_diff = (cpu_r["final_logits"] - mps_r["final_logits"]).abs().max().item()
        logit_scale = cpu_r["final_logits"].abs().max().item()
        resid_diff = max(
            (cpu_r["resid"][k] - mps_r["resid"][k]).abs().max().item() for k in cpu_r["resid"]
        )
        top1_match = cpu_r["final_logits"].argmax() == mps_r["final_logits"].argmax()
        print(f"  '{prompt[:40]}...': max logit diff {logit_diff:.4f} "
              f"(scale {logit_scale:.1f}), max resid diff {resid_diff:.4f}, "
              f"top1 {'MATCH' if top1_match else 'MISMATCH!'}")

    if cpu_ioi is not None:
        flip = " <-- SIGN FLIP!" if (cpu_ioi > 0) != (mps_ioi > 0) else ""
        print(f"  IOI logit diff (Mary-John): CPU {cpu_ioi:+.3f} vs MPS {mps_ioi:+.3f}{flip}")


if __name__ == "__main__":
    compare("gpt2", torch.float32)
    compare("google/gemma-2-2b-it", torch.bfloat16)
    print("\nDone.")
