{ self
, nixpkgs
, release
, hostSystem
, dockerTools
, glibcLocalesUtf8
, coreutils
, curl
, ...
}:
let
  hostPkgs = import nixpkgs { system = hostSystem; };

  name = release.pname;
  tag =
    if self ? shortRev then
      "${release.version}-${self.shortRev}"
    else
      throw "Refuse to build docker image from a dirty Git tree.";
in
(dockerTools.override {
  writePython3 = hostPkgs.buildPackages.writers.writePython3;
}).streamLayeredImage {
  inherit name tag;

  contents = [
    dockerTools.caCertificates
    dockerTools.binSh

    coreutils

    # healthcheck related packages
    curl
  ];

  config = {
    Env = [
      "LOCALE_ARCHIVE=${glibcLocalesUtf8}/lib/locale/locale-archive"
      "LANG=en_US.UTF-8"
    ];
    WorkingDir = release;
    Cmd = [ "${release}/bin/server" "start" ];
  };
}
