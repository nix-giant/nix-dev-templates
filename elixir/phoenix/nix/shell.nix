{
  stdenv,
  lib,
  mkShell,
  myEnv,
  libnotify,
  inotify-tools,
  terminal-notifier,
  darwin,
  ...
}:
mkShell {
  packages =
    [
      myEnv.beamPackages.erlang
      myEnv.beamPackages.elixir
      myEnv.nodePackages.nodejs
    ]
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

    # limit hex to current project
    mkdir -p .nix-hex
    export HEX_HOME=$PWD/.nix-hex
    export ERL_LIBS=$HEX_HOME/lib/erlang/lib
    export PATH=$HEX_HOME/bin:$PATH

    # limit history to current project
    export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.erlang-history\"'"
  '';
}
