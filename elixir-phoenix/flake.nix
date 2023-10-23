{
  description = "Elixir development environment for Phoenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = with pkgs; mkShell {
          packages = [
            beam.packages.erlangR25.elixir_1_14
            nodejs_18
          ] ++
          # Linux only
          lib.optionals stdenv.isLinux [
            # for ExUnit notifier
            libnotify

            # for package - file_system
            inotify-tools
          ] ++
          # macOS only
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
            mkdir -p .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export ERL_LIBS=$HEX_HOME/lib/erlang/lib

            # rewire executables
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$MIX_HOME/escripts:$PATH
            export PATH=$HEX_HOME/bin:$PATH

            # limit history to current project
            export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.erlang-history\"'"
          '';
        };
      });
    };
}
