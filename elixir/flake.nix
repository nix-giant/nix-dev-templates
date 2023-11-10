{
  description = "Elixir development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
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
            app = pkgs.myCallPackage ./nix/app.nix { };

            buildDockerImage = hostSystem: pkgs.myCallPackage ./nix/docker-image.nix ({
              inherit app hostSystem;
            } // inputs);
            docker-images = builtins.listToAttrs (map
              (hostSystem: {
                name = "docker-image-trigger-by-${hostSystem}";
                value = buildDockerImage hostSystem;
              })
              flake-utils.lib.defaultSystems);
          in
          { inherit app; } // docker-images;
      }
    );
}
