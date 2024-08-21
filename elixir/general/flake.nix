{
  description = "Elixir development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            packages =
              [ beam.packages.erlang_26.elixir_1_15 ]
              ++
              # Linux only
              lib.optionals stdenv.isLinux [
                # for ExUnit notifier
                libnotify

                # for package - file_system
                inotify-tools
              ]
              ++
                # Darwin only
                lib.optionals stdenv.isDarwin [
                  # for ExUnit notifier
                  terminal-notifier

                  # for package - file_system
                  darwin.apple_sdk.frameworks.CoreFoundation
                  darwin.apple_sdk.frameworks.CoreServices
                ];

            shellHook = ''
              # limit mix to current project
              mkdir -p .nix-mix
              export MIX_HOME=$PWD/.nix-mix
              export PATH=$MIX_HOME/bin:$PATH
              export PATH=$MIX_HOME/escripts:$PATH

              # limit history to current project
              export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.erlang-history\"'"
            '';
          };
      }
    );
}
