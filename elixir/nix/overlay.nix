_final: prev:
let
  pkgs = prev;

  buildBeamPackages = scope:
    let
      beamPackages = with scope; packagesWith interpreters.erlang_26;

      erlang = beamPackages.erlang;
      elixir = beamPackages.elixir_1_15;

      fetchMixDeps = beamPackages.fetchMixDeps.override { inherit elixir; };
      mixRelease = beamPackages.mixRelease.override { inherit elixir erlang fetchMixDeps; };
    in
    { inherit erlang elixir fetchMixDeps mixRelease; };

  buildNodePackages = scope: {
    nodejs = scope.nodejs_18;
  };
in
rec {
  myEnv = {
    beamPackages = (buildBeamPackages pkgs.beam) // {
      minimal = buildBeamPackages pkgs.beam_minimal;
    };
    nodePackages = buildNodePackages pkgs;
  };

  myCallPackage = pkgs.lib.callPackageWith (pkgs // {
    inherit myEnv;
  });
}
