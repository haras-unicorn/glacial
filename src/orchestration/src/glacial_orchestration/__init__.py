import typer
import watchfiles
import time
import socketserver
import threading
import tempfile
from http.server import SimpleHTTPRequestHandler
from pathlib import Path
from playwright import sync_api as playwright

main = typer.Typer()


@main.command()
def run(file: Path) -> None:
  if file.suffix != ".js":
    raise typer.BadParameter(f"Wtf is this {file.suffix} thing???")

  if not file.exists():
    raise typer.BadParameter(f"{file} does not exist 💀")

  if not file.is_file():
    raise typer.BadParameter(f"{file} is not a file (maybe a dir?) 🚫")

  root = tempfile.mkdtemp(prefix="glacial-orchestration-dev-root-")

  class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kw):  # type: ignore[no-untyped-def]
      super().__init__(*args, directory=str(root), **kw)

  server = socketserver.TCPServer(("127.0.0.1", 0), Handler)
  port = server.server_address[1]
  thread = threading.Thread(target=server.serve_forever, daemon=True)
  thread.start()

  manager = playwright.sync_playwright()
  context = manager.start()
  browser = context.chromium.launch(
    headless=False,
    args=["--autoplay-policy=no-user-gesture-required"],
  )

  page = browser.new_page()
  page.goto(f"127.0.0.1:{port}")

  def reload() -> None:
    try:
      content = None
      with open(file, "r") as buffer:
        content = buffer.read()

      content = f"""
        <!doctype html>
        <html>
          <body>
            <div id="root"></div>
            <script type="module">
              {content}
            </script>
          </body>
        </html>
      """
      page.set_content(content)

    except KeyboardInterrupt as interrupt:
      raise interrupt
    except Exception as error:
      typer.echo(f"Oopsie 😅\n{error}", err=True)

  try:
    while True:
      typer.echo("On it! 🤓")
      reload()
      try:
        for events in watchfiles.watch(file):
          rewatch = False
          for type, _ in events:
            if type != watchfiles.Change.deleted:
              typer.echo("Reloading! 🫡")
              reload()
            else:
              typer.echo("You deleted the file! 😨")
              rewatch = True
          if rewatch:
            break
      except FileNotFoundError:
        typer.echo("The file is not there... 🤔")
        time.sleep(1)
        continue

  except KeyboardInterrupt:
    pass

  finally:
    try:
      browser.close()
    except Exception:
      pass

    context.stop()

    server.shutdown()
    thread.join()


if __name__ == "__main__":
  main()
