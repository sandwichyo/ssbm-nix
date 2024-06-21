{
  slippi-desktop,
  final,
  prev,
}:
with final.pkgs; rec {
  wiimms-iso-tools = callPackage ./wit {};

  gecko = callPackage ./gecko {};

  powerpc-eabi-assembling = callPackage ./powerpc-eabi-as {};

  slippi-playback = callPackage ./slippi {
    inherit slippi-desktop;
    playbackSlippi = true;
  };

  slippi-netplay = callPackage ./slippi {
    inherit slippi-desktop;
    playbackSlippi = false;
  };

  slippi-launcher = callPackage ./slippi-launcher {};

  gcmtool = callPackage ./gcmtool {};

  projectplus-sdcard = callPackage ./pplus/sdcard.nix {};
  projectplus-config = callPackage ./pplus/config.nix {};

  dat-texture-wizard = callPackage ./dtw {inherit cxfreeze;};

  cxfreeze = callPackage ./dtw/cxfreeze.nix {};

  keyb0xx = callPackage ./keyb0xx {};
}
