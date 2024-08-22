_final: prev:
let
  pkgs = prev;

  buildBeamPackages =
    scope:
    let
      beamPackages = with scope; packagesWith interpreters.erlang_27;

      erlang = beamPackages.erlang;
      elixir = beamPackages.elixir_1_17;

      fetchMixDeps = pkgs.beamUtils.fetchMixDeps.override { inherit elixir; };
      buildMixRelease = pkgs.beamUtils.buildMixRelease.override { inherit erlang elixir; };
    in
    {
      inherit
        erlang
        elixir
        fetchMixDeps
        buildMixRelease
        ;
    };

  buildNodePackages = scope: rec {
    nodejs = scope.nodejs_20;

    fetchNpmDeps =
      {
        pname,
        version,
        src,
        hash,
        postBuild ? "",
      }:
      let
        inherit (scope) stdenv buildPackages fetchNpmDeps;
        npmHooks = buildPackages.npmHooks.override { inherit nodejs; };
      in
      stdenv.mkDerivation {
        name = "${pname}-${version}";
        inherit src;
        npmDeps = fetchNpmDeps {
          name = "${pname}-cache-${version}";
          inherit src hash;
        };
        nativeBuildInputs = [
          nodejs
          npmHooks.npmConfigHook
        ];
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

  myCallPackage = pkgs.lib.callPackageWith (pkgs // { inherit myEnv; });
}
