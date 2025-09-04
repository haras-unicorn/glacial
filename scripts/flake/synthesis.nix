{ self, pkgs, ... }:

{
  integrate.package.nixpkgs.config.allowUnfree = true;
  integrate.package.package = self.lib.python.mkPackage pkgs "glacial-synthesis";
}
