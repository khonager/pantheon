{
  description = "Pantheon - Khonager's Personal Repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # 1. Add Teros as a source input (Not a flake, just files)
    teros-src = {
      url = "github:khonager/teros";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, teros-src }: # <--- Add teros-src here
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      overlays.default = final: prev: {
        # 2. Pass the downloaded source directly to the package
        teros = prev.callPackage ./pkgs/teros/default.nix {
          source = teros-src;
        };
      };
    };
}
