{
  nixpkgs,
  release,
  hostSystem,
  dockerTools,
  glibcLocalesUtf8,
  coreutils,
  curl,
  ...
}:
let
  hostPkgs = import nixpkgs { system = hostSystem; };
  name = release.pname;
in
(dockerTools.override { writePython3 = hostPkgs.buildPackages.writers.writePython3; })
.streamLayeredImage
  {
    inherit name;
    tag = "latest";

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
        "LC_ALL=en_US.UTF-8"
        "TERM=vt100"
      ];
      WorkingDir = release;
      Cmd = [
        "${release}/bin/server"
        "start"
      ];
    };
  }
