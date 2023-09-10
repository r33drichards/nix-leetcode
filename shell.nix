{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = [
    pkgs.git
    pkgs.nixpkgs-fmt
    pkgs.jq
    pkgs.just
    pkgs.watch
  ];
}
