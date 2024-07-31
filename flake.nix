{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  description = "Nix expressions for Super Smash Bros. Melee players.";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in {
    overlays.default = final: prev: import ./overlay.nix {inherit final prev;};

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    apps = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      slippi-netplay = {
        type = "app";
        program = "${pkgs.slippi-netplay}/bin/slippi-netplay";
      };
      slippi-playback = {
        type = "app";
        program = "${pkgs.slippi-playback}/bin/slippi-playback";
      };
    });

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      inherit
        (pkgs)
        # dat-texture-wizard
        
        wiimms-iso-tools
        slippi-netplay
        slippi-playback
        slippi-launcher
        gecko
        powerpc-eabi-assembling
        gcmtool
        projectplus-sdcard
        projectplus-config
        keyb0xx
        ;
    });

    overlay = {nixpkgs.overlays = [ self.overlays.default ];};


    nixosModule = self.outputs.nixosModules.default;
    nixosModules.default = {config, ...}: let
      cfg = config.ssbm;
    in
      with nixpkgs.lib; {
        options.ssbm = {
          cache.enable = mkEnableOption "Turn on cache.";
          gcc.oc-kmod.enable = mkEnableOption "Turn on overclocking kernel module.";
          gcc.rules.enable = mkEnableOption "Turn on rules for your gamecube controller adapter.";
          gcc.rules.rules = mkOption {
            default = readFile ./gcc.rules;
            type = types.lines;
            description = "To be appended to services.udev.extraRules if gcc.rules.enable is set.";
          };
          keyb0xx = {
            enable = mkEnableOption "Add keyb0xx to your binary path";
            config = mkOption {
              default = readFile ./keyb0xx/config.h;
              type = types.lines;
              description = "Config.h file to compile keyb0xx with.";
            };
          };
        };
        config = {
          services.udev.extraRules = mkIf cfg.gcc.rules.enable cfg.gcc.rules.rules;
          boot.kernelModules = mkIf cfg.gcc.oc-kmod.enable ["gcadapter_oc"];
          boot.extraModulePackages = mkIf cfg.gcc.oc-kmod.enable [
            config.boot.kernelPackages.gcadapter-oc-kmod
          ];
          nix = mkIf cfg.cache.enable {
            settings.substituters = ["https://ssbm-nix.cachix.org"];
            settings.trusted-public-keys = ["ssbm-nix.cachix.org-1:YN104LKAWaKQIecOphkftXgXlYZVK/IRHM1UD7WAIew="];
          };
          environment.systemPackages = [(mkIf cfg.keyb0xx.enable (pkgs.keyb0xx.override {keyb0xxconfig = cfg.keyb0xx.config;}))];
        };
      };

    homeManagerModule = self.outputs.homeManagerModules.default;
    homeManagerModules.default = {
      pkgs,
      config,
      lib,
      ...
    }: let
      cfg = config.ssbm;
    in
      with lib; {
        options.ssbm = {
          slippi-launcher = {
            enable = mkEnableOption "Install Slippi Launcher";
            # Game settings
            isoPath = mkOption {
              default = "";
              type = types.str;
              description = "The path to an NTSC Melee ISO.";
            };
            launchMeleeOnPlay = mkEnableOption "Launch Melee in Dolphin when the Play button is pressed." // {default = true;};
            enableJukebox = mkEnableOption "Enable in-game music via Slippi Jukebox. Incompatible with WASAPI." // {default = true;};
            # Replay settings
            rootSlpPath = mkOption {
              default = "${config.home.homeDirectory}/Slippi";
              type = types.str;
              description = "The folder where your SLP replays should be saved.";
            };
            useMonthlySubfolders = mkEnableOption "Save replays to monthly subfolders";
            spectateSlpPath = mkOption {
              default = "${cfg.slippi-launcher.rootSlpPath}/Spectate";
              type = types.nullOr types.str;
              description = "The folder where spectated games should be saved.";
            };
            extraSlpPaths = mkOption {
              default = [];
              type = types.listOf types.str;
              description = "Choose any additional SLP directories that should show up in the replay browser.";
            };
            # Netplay
            netplayDolphinPath = mkOption {
              default = "${pkgs.slippi-netplay}/";
              type = types.str;
              description = "The path to the folder containing the Netplay Dolphin Executable";
            };
            # Playback
            playbackDolphinPath = mkOption {
              default = "${pkgs.slippi-playback}/";
              type = types.str;
              description = "The path to the folder containing the Playback Dolphin Executable";
            };
          };
        };
        config = mkIf cfg.slippi-launcher.enable {
          nixpkgs.overlays = [self.overlays.default];
          home.packages = [pkgs.slippi-launcher];
          xdg.configFile."Slippi Launcher/Settings".source = let
            jsonFormat = pkgs.formats.json {};
          in
            jsonFormat.generate "slippi-config" {
              settings = {
                isoPath = cfg.slippi-launcher.isoPath;
                launchMeleeOnPlay = cfg.slippi-launcher.launchMeleeOnPlay;
                enableJukebox = cfg.slippi-launcher.enableJukebox;
                # Replay settings
                rootSlpPath = cfg.slippi-launcher.rootSlpPath;
                useMonthlySubfolders = cfg.slippi-launcher.useMonthlySubfolders;
                spectateSlpPath = cfg.slippi-launcher.spectateSlpPath;
                extraSlpPaths = cfg.slippi-launcher.extraSlpPaths;
                # Advanced settings
                autoUpdateLauncher = false;
              };
            };
        };
      };
  };
}
