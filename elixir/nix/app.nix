{ lib, myEnv, ... }:
let
  pname = "demo";
  version = "0.1.0";
  src = ../.;

  inherit (myEnv.beamPackages.minimal) fetchMixDeps mixRelease;

  mixFodDeps = fetchMixDeps {
    pname = "${pname}-mix-deps";
    inherit src version;
    sha256 = lib.fakeHash;
  };
in
mixRelease {
  inherit pname version src;
  inherit mixFodDeps;

  nativeBuildInputs = [ ];
}
