{ pkgs, lib, fetchFromGitHub, buildNpmPackage, makeWrapper, nodejs, ... }:

buildNpmPackage rec {
  pname = "antigravity-shit-chat";
  version = "81d513b";

  src = fetchFromGitHub {
    owner = "gherghett";
    repo = "Antigravity-Shit-Chat";
    rev = "81d513b71096e20d6a329e5a0d29233f2c10b6e6";
    hash = "sha256-Er2PWkU1QfS3xb1P3P7Fvi81XwN3uwnx+l4Kbr4Ae/I=";
  };

  # Use postPatch to copy the lockfile so it's available for the npm-deps derivation
  postPatch = ''
    cp ${./package-lock.json} package-lock.json

    # Patch server.js to allow configuring the CDP port via environment variable
    substituteInPlace server.js \
      --replace "const PORTS = [9000, 9001, 9002, 9003];" \
                "const PORTS = [ parseInt(process.env.CDP_PORT) || 9000, 9001, 9002, 9003 ];"
  '';

  npmDepsHash = "sha256-Eac1WwbaVEpIS6/oz9WHHbNsAEsursroFhE1EQQhMl4=";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/antigravity-shit-chat
    cp -r . $out/lib/node_modules/antigravity-shit-chat
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/antigravity-shit-chat \
      --add-flags "$out/lib/node_modules/antigravity-shit-chat/server.js"
    runHook postInstall
  '';

  nativeBuildInputs = [ makeWrapper ];
}
