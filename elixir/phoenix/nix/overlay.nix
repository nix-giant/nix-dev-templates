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

  buildNodePackages = scope: rec {
    nodejs = scope.nodejs_18;

    fetchNpmDeps = { pname, version, src, hash, postBuild ? "" }:
      let
        inherit (scope) stdenv buildPackages fetchNpmDeps;
        npmHooks = buildPackages.npmHooks.override { inherit nodejs; };
      in
      stdenv.mkDerivation {
        name = "${pname}-${version}";
        inherit src;
        npmDeps = fetchNpmDeps { inherit src hash; };
        nativeBuildInputs = [ nodejs npmHooks.npmConfigHook ];
        postBuild = postBuild;
        installPhase = ''
          mkdir -p "$out"
          cp -r package.json package-lock.json node_modules "$out"
        '';
      };
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
