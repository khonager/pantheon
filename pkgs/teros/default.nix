{ lib, stdenv, source }: # <--- Now accepts 'source' as an argument

stdenv.mkDerivation {
  pname = "teros-theme-pack";
  version = "1.0";

  # Use the source passed from the Flake (no hash needed here!)
  src = source;

  installPhase = ''
    themeDir="$out/share/plymouth/themes"
    mkdir -p $themeDir
    
    # The source might be read-only, so we copy carefully
    cp -r themes/* $themeDir

    find $themeDir -name "*.plymouth" | while read file; do
      dir=$(dirname "$file")
      sed -i "s@ImageDir=.*@ImageDir=$dir@" "$file"
      sed -i "s@ScriptFile=\./@ScriptFile=$dir/@" "$file"
      sed -i "s@ScriptFile=\([^/]\)@ScriptFile=$dir/\1@" "$file"
    done
  '';

  meta = with lib; {
    description = "Khonager's Teros Theme Pack";
    platforms = platforms.linux;
  };
}
