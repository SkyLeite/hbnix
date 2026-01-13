{
  runCommand,
  lib,
  fetchFromGitHub,
  vitaPackages,
  self,
  ...
}:
let
  mkVitaSample =
    name: input:
    self.mkVitaPackage (
      input
      // {
        inherit name;
        src = fetchFromGitHub {
          owner = "vitasdk";
          repo = "samples";
          rev = "2cf7451bfec53929bcc727937819078da31d1b9c";
          hash = "sha256-umhsp0ANfjX15s+PuM99aEkI+sNOoEwiQrwey1+uON0=";
        };

        prePatch = ''
          mv common/ ${name}/

          pushd ${name}

          substituteInPlace CMakeLists.txt \
            --replace-fail "../common" "common"

          if [[ -f "src/main.cpp" ]]; then
            substituteInPlace src/main.cpp \
              --replace-fail "<debugScreen.h>" "\"../common/debugScreen.h\""
          fi

          if [[ -f "Makefile" ]]; then
            rm Makefile
          fi
        '';
      }
    );
in
{
  vitaHelloWorld = mkVitaSample "hello_cpp_world" { };
  vitaSDL2 = mkVitaSample "sdl2/redrectangle" {
    buildInputs = [ vitaPackages.sdl2 ];
  };
}
