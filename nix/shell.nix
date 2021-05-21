{ pkgs ? import <nixpkgs> {} }:
with pkgs;
  mkShell {
    nativeBuildInputs = [ 
        ruby 
        git 
        sqlite
        libpcap
        postgresql
        libxml2
        libxslt
        pkg-config
        bundler
        bundix
        gnumake
        qt5.qtwebkit
        qt5.qtbase
        qt5.qmake
        libpqxx
        jre
        gst_all_1.gstreamer
                        ];
}

#using the standard environment (customize)

# with import <nixpkgs> {};
# stdenv.mkDerivation {
#   name = "env";
#   buildInputs = [
#     ruby.devEnv
#     git
#     sqlite
#     libpcap
#     postgresql
#     libxml2
#     libxslt
#     pkg-config
#     bundix
#     gnumake
#     qt5.qtwebkit
#     qt5.qtbase
#     qt5.qmake
#     libpqxx
#   ];
# }