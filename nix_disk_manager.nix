{ lib, flutter, dart, zlib, gtk3, pkg-config, libtool, libGL, libX11 }:

# Define the Flutter app package
flutter.buildFlutterApplication rec {
  pname = "nix_disk_manager";
  version = "1.0.5";

  src = ./.; # Your source code directory (current directory)

  autoPubspecLock = ./pubspec.lock;

  buildInputs = [ flutter dart zlib gtk3 pkg-config libtool libGL libX11 ];


  buidPhase = ''
    export GDK_BACKEND=x11
    export LIBGL_ALWAYS_SOFTWARE=1  # Use software rendering for OpenGL

    export PRETTY_NAME="Linux"
  '';

}
