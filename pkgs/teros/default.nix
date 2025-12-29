{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "teros-theme-pack";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "khonager";
    repo = "teros";
    rev = "COMMIT_HASH_HERE"; # Update this after you push your themes!
    sha256 = lib.fakeSha256;
  };

  installPhase = ''
    # Destination in the Nix Store
    themeDir="$out/share/plymouth/themes"
    mkdir -p $themeDir

    # Copy contents of the 'themes' folder from your repo
    # This results in $out/share/plymouth/themes/shiro and .../sora
    cp -r themes/* $themeDir

    # Fix paths for EVERY .plymouth file in all subfolders
    find $themeDir -name "*.plymouth" | while read file; do
      dir=$(dirname "$file")
      
      # 1. Point ImageDir to the theme folder
      sed -i "s@ImageDir=.*@ImageDir=$dir@" "$file"
      
      # 2. Point ScriptFile to the theme folder (handling local paths)
      # This regex takes "ScriptFile=./sora.script" and turns it into "ScriptFile=/nix/store/.../sora.script"
      sed -i "s@ScriptFile=\./@ScriptFile=$dir/@" "$file"
      sed -i "s@ScriptFile=\([^/]\)@ScriptFile=$dir/\1@" "$file"
    done
  '';

  meta = with lib; {
    description = "Khonager's Teros Theme Pack (Sora & Shiro)";
    platforms = platforms.linux;
  };
}
