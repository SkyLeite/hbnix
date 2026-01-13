{
  stdenv,
  vitaPackages,
  cmake,
  lib,
  gcc,
}:
{
  mkVitaPackage =
    input:
    stdenv.mkDerivation (
      input
      // rec {
        buildInputs = (input.buildInputs or [ ]) ++ [
          cmake
          vitaPackages.vitasdk
        ];

        VITASDK = "${vitaPackages.vitasdk}";

        cmakeFlags = (input.cmakeFlags or [ ]) ++ [
          (lib.cmakeFeature "CMAKE_TOOLCHAIN_FILE" "${VITASDK}/share/vita.toolchain.cmake")
          (lib.cmakeFeature "CMAKE_C_COMPILER" "${VITASDK}/bin/arm-vita-eabi-gcc")
          (lib.cmakeFeature "CMAKE_CXX_COMPILER" "${VITASDK}/bin/arm-vita-eabi-g++")
          (lib.cmakeFeature "VITA" "TRUE")
        ];

        installPhase = ''
          mkdir -p $out
          mv *.vpk $out
        '';
      }
    );
}
