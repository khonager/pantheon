{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "teros-theme-pack"; # Renamed since it's now a pack
  version = "1.0";

  src = fetchFromGitHub {
    owner = "khonager";
    repo = "teros";
    rev = "COMMIT_HASH_HERE";
    sha256 = lib.fakeSha256;
  };

  installPhase = ''
    # 1. Prepare the destination
    themeDir="$out/share/plymouth/themes"
    mkdir -p $themeDir

    # 2. Copy ALL folders from your repo to the Nix Store
    cp -r * $themeDir

    # 3. Smart Loop: Fix paths for EVERY .plymouth file found
    # This automatically finds 'rings.plymouth', 'teros-titan.plymouth', etc.
    # and points them to the correct Nix store paths.
    
    find $themeDir -name "*.plymouth" | while read file; do
      # Get the folder where the file lives
      dir=$(dirname "$file")
      
      # Update ImageDir to the current Nix store path
      sed -i "s@ImageDir=.*@ImageDir=$dir@" "$file"
      
      # Update ScriptFile (Assumes script name matches folder name or is defined in .plymouth)
      # We use a regex to capture whatever script file was originally defined and prepend the path
      sed -i "s@ScriptFile=\(.*\)$@ScriptFile=$dir/\1@" "$file"
      
      # Cleanup: Remove the explicit "./" if the user added it, to avoid double slashes
      sed -i "s@$dir/\./@$dir/@" "$file"
    done
  '';

  meta = with lib; {
    description = "Khonager's Plymouth Theme Collection";
    platforms = platforms.linux;
  };
}
