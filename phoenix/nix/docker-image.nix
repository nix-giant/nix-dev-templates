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

  # TODO: adjust url for health check
  healthCheckUrl = "http://127.0.0.1:4000/health-check";
in
(dockerTools.override {
  writePython3 = hostPkgs.buildPackages.writers.writePython3;
}).streamLayeredImage {
  inherit name tag;

  contents = [
    dockerTools.caCertificates
    dockerTools.binSh

    coreutils
  ];

  config = {
    Env = [
      "LOCALE_ARCHIVE=${glibcLocalesUtf8}/lib/locale/locale-archive"
      "LANG=en_US.UTF-8"
    ];
    WorkingDir = release;
    Cmd = [ "${release}/bin/server" "start" ];
    Healthcheck =
      let
        nanoseconds = seconds: seconds * 1000000000;
      in
      {
        Test = [
          "CMD-SHELL"
          "${curl}/bin/curl --output /dev/null --silent --fail ${healthCheckUrl}"
        ];
        Interval = nanoseconds 5;
        Timeout = nanoseconds 3;
        StartPeriod = nanoseconds 3;
        Retries = 3;
      };
  };
}
