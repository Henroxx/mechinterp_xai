"""Smoke test: verify the mech-interp stack works end to end.

Loads gemma-2-2b-it and gpt2 in TransformerLens on Apple Silicon (MPS),
generates a few tokens, and runs run_with_cache once to check that
activation caching works and to report its memory footprint.

Run:  uv run python scripts/smoke_test.py
"""

import time

import torch
from transformer_lens import HookedTransformer

DEVICE = "mps" if torch.backends.mps.is_available() else "cpu"


def report_cache_size(cache) -> float:
    """Total size of all cached activation tensors in GB."""
    total_bytes = sum(t.numel() * t.element_size() for t in cache.values())
    return total_bytes / 1e9


def smoke_test(model_name: str, prompt: str, chat_wrap: bool = False) -> None:
    print(f"\n=== {model_name} on {DEVICE} ===")

    t0 = time.time()
    model = HookedTransformer.from_pretrained(model_name, device=DEVICE, dtype=torch.bfloat16)
    print(f"loaded in {time.time() - t0:.1f}s | layers={model.cfg.n_layers}, d_model={model.cfg.d_model}")

    if chat_wrap:
        prompt = f"<start_of_turn>user\n{prompt}<end_of_turn>\n<start_of_turn>model\n"

    t0 = time.time()
    output = model.generate(prompt, max_new_tokens=30, temperature=0.7, verbose=False)
    print(f"generated in {time.time() - t0:.1f}s:\n---\n{output}\n---")

    t0 = time.time()
    _, cache = model.run_with_cache(prompt)
    print(f"run_with_cache in {time.time() - t0:.1f}s | cache size: {report_cache_size(cache):.2f} GB "
          f"({len(cache)} activation tensors)")

    del model, cache


if __name__ == "__main__":
    smoke_test("google/gemma-2-2b-it", "Explain in one sentence what a transformer is.", chat_wrap=True)
    smoke_test("gpt2", "The capital of France is")
    print("\nAll smoke tests passed.")
