{ hostSystem
, nixpkgs
, dockerTools
, glibcLocalesUtf8
, coreutils
, app
, ...
}:
let
  appName = app.pname;
  hostPkgs = import nixpkgs { system = hostSystem; };
in
(dockerTools.override {
  writePython3 = hostPkgs.buildPackages.writers.writePython3;
}).streamLayeredImage {
  name = appName;
  tag = "latest";

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
    WorkingDir = app;
    Cmd = [ "${app}/bin/${appName}" "start" ];
  };
}
