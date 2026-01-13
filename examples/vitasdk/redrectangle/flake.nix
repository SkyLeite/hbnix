{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    hbnix.url = "github:SkyLeite/hbnix";
  };

  outputs =
    {
      self,
      nixpkgs,
      hbnix,
    }:
    let
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system: function nixpkgs.legacyPackages.${system} system);

      hbn = forAllSystems (pkgs: system: pkgs.callPackage hbnix."${system}");
    in
    {
      packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
    };
}
