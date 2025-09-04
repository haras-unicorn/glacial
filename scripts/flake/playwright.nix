{
  self,
  nixpkgsPlaywright,
  ...
}:

{
  flake.lib.playwright.packages =
    system:
    let
      playwrightPkgs = import nixpkgsPlaywright {
        inherit system;
      };
    in
    {
      node = playwrightPkgs.nodejs;
      browsers =
        if playwrightPkgs.hostPlatform.isLinux then
          playwrightPkgs.playwright-driver.browsers.override {
            withFirefox = false;
            withWebkit = false;
          }
        else
          playwrightPkgs.playwright-driver.browsers;
    };

  flake.lib.playwright.env =
    system:
    let
      packages = self.lib.playwright.packages system;
    in
    {
      PLAYWRIGHT_NODEJS_PATH = "${packages.node}/bin/node";
      PLAYWRIGHT_BROWSERS_PATH = "${packages.browsers}";
    };
}
