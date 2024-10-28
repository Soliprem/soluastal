{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, astal }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = astal.lib.mkLuaPackage {
      inherit pkgs;
      src = /home/soliprem/.local/src/libastal-bar; # should contain init.lua

      # add extra glib packages or binaries
      extraPackages = [
        astal.packages.${system}.battery
        astal.packages.${system}.mpris
        astal.packages.${system}.wireplumber
        astal.packages.${system}.network
        astal.packages.${system}.hyprland
        astal.packages.${system}.notifd
        astal.packages.${system}.tray
        pkgs.dart-sass
      ];
    };
  };
}
