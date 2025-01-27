{
  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cargo2nix.overlays.default ];
        };

        rustPkgs = pkgs.rustBuilder.makePackageSet {
          packageOverrides = pkgs: pkgs.rustBuilder.overrides.all ++ [
            (pkgs.rustBuilder.rustLib.makeOverride {
              name = "ocaml-boxroot-sys";
              overrideAttrs = drv: {
                buildInputs = drv.buildInputs ++ [ pkgs.ocaml ];
              };
            })
          ];
          rustVersion = "1.70.0";
          packageFun = import ./Cargo.nix;
        };

      in
      rec {
        packages = {
          # replace hhello-world with your package name
          rust-ocaml-starter = (rustPkgs.workspace.rust-ocaml-starter { });
          default = packages.rust-ocaml-starter;
        };
      }
    );
}
