{
  description = "Elixir development environment for Phoenix project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import ./nix/overlay.nix) ];
        };
      in
      {
        devShells = {
          default = pkgs.myCallPackage ./nix/shell.nix { };
        };

        packages =
          let
            release = pkgs.myCallPackage ./nix/release.nix { };

            buildDockerImage = hostSystem: pkgs.myCallPackage ./nix/docker-image.nix ({
              inherit release hostSystem;
            } // inputs);
            docker-images = builtins.listToAttrs (map
              (hostSystem: {
                name = "docker-image-triggered-by-${hostSystem}";
                value = buildDockerImage hostSystem;
              })
              flake-utils.lib.defaultSystems);
          in
          { inherit release; } // docker-images;
      }
    );
}
