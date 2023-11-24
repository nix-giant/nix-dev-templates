{
  description = "Shell development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/6f314053897165a8c629484836a45d1de1a0e965";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = with pkgs; mkShell {
          packages = [
            bash
          ];
        };
      }
    );
}
