{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  libgcc,
}:
let
  versionInfo = lib.importJSON ./version.json;
  version = versionInfo.version;

  platformMap = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-amd64";
    "aarch64-darwin" = "darwin-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  hash = versionInfo.hashes.${platform};

  baseUrl = "https://sprites-binaries.t3.storage.dev/client";
in
stdenv.mkDerivation {
  pname = "sprite";
  inherit version;

  src = fetchurl {
    url = "${baseUrl}/${version}/sprite-${platform}.tar.gz";
    inherit hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    zlib
    libgcc.lib
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 sprite $out/bin/sprite
    runHook postInstall
  '';

  meta = {
    description = "Sprite CLI";
    homepage = "https://sprites.dev";
    platforms = lib.attrNames platformMap;
    mainProgram = "sprite";
  };
}
