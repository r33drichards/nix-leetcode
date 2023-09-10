{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = [
    pkgs.git
    pkgs.nixfmt
    pkgs.jq
    pkgs.just
  ];
}
