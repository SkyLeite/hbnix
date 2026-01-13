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
      mkPkgs =
        system:
        import nixpkgs {
          system = system;
          overlays = [
            (final: prev: ({
              vitaPackages = vitasdk.packages."${system}";
            }))
          ];
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
      lib = builtins.trace lib.x86_64-linux.mkVitaPackage lib;
    };
}
