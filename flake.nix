{
  description = "A collection of Nix flake templates for development.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      overlays = [
        (final: prev:
          let
            exec = pkg: "${prev.${pkg}}/bin/${pkg}";
          in
          {
            format = prev.writeScriptBin "format" ''
              ${exec "nixpkgs-fmt"} **/*.nix
            '';
            update = prev.writeScriptBin "update" ''
              for dir in `ls -d */`; do # Iterate through all the templates
                (
                  cd $dir
                  ${exec "nix"} flake update # Update flake.lock
                  ${exec "nix"} flake check  # Make sure things work after the update
                )
              done
            '';
            dvt = prev.writeScriptBin "dvt" ''
              if [ -z $1 ]; then
                echo "no template specified"
                exit 1
              fi

              TEMPLATE=$1

              ${exec "nix"} \
                --experimental-features 'nix-command flakes' \
                flake init \
                --template \
                "github:c4710n/nix-dev-templates#''${TEMPLATE}"
            '';
          })
      ];

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system overlays; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ format update ];
        };
      });

      packages = forEachSupportedSystem ({ pkgs }: rec {
        default = dvt;
        inherit (pkgs) dvt;
      });

    }

    //

    {
      templates = {
        elixir = {
          path = ./elixir;
          description = "Elixir development environment";
        };
      };
    };
}
