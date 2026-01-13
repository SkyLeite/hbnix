{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    vitasdk.url = "github:sleirsgoevy/vitasdk.nix";
  };

  outputs =

    {
      self,
      nixpkgs,
      vitasdk,
    }:
    let
      overlay = final: prev: {
        vitaPackages = vitasdk.packages."${final.stdenv.hostPlatform.system}";
      };

      mkPkgs =
        system:
        import nixpkgs {
          system = system;
          overlays = [ overlay ];
        };

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system: function (mkPkgs system) system);

      lib = forAllSystems (pkgs: system: pkgs.callPackage ./lib.nix { });
    in
    {
      checks = forAllSystems (pkgs: system: import ./checks.nix (pkgs // { self = lib."${system}"; }));
      lib = lib;
      overlays.default = overlay;
    };
}
