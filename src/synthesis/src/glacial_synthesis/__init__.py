import typer

main = typer.Typer()


@main.command()
def generate(prompt: str, duration: int = 8, out: str = "out.wav") -> None:
  import warnings

  warnings.filterwarnings(
    "ignore",
    message=(
      "torch.nn.utils.weight_norm is deprecated"
      + " in favor of torch.nn.utils.parametrizations.weight_norm."
    ),
    category=UserWarning,
    module="torch.nn.utils.weight_norm",
  )

  import soundfile
  import torch
  from audiocraft.models.musicgen import MusicGen

  device = "cuda" if torch.cuda.is_available() else "cpu"
  typer.echo(f"Using device: {device}")
  model = MusicGen.get_pretrained("facebook/musicgen-small", device=device)
  model.set_generation_params(duration=duration)
  wav = model.generate([prompt])[0][0].cpu().numpy()
  soundfile.write(out, wav, model.sample_rate)  # type: ignore[no-untyped-call]
  typer.echo(f"Saved {out}")


if __name__ == "__main__":
  main()
