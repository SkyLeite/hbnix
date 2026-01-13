{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    hbnix.url = "github:SkyLeite/hbnix?ref=main";
  };

  outputs =
    {
      self,
      nixpkgs,
      hbnix,
    }:
    let
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ hbnix.overlays.default ];
        };

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system: function (mkPkgs system) system);

      hbn = forAllSystems (pkgs: system: hbnix.lib."${system}");
    in
    {
      packages = forAllSystems (
        pkgs: system: {
          default = (
            hbn.mkVitaPackage {
              name = "redrectangle";
              src = ./.;
              buildInputs = [ pkgs.vitaPackages.sdl2 ];
            }
          );
        }
      );
    };
}
