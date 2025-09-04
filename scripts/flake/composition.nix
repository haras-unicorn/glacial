{ self, pkgs, ... }:

{
  integrate.package.package = self.lib.javascript.mkPackage pkgs "glacial-composition";
}
