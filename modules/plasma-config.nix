{
  programs.plasma = {
    enable = true;

    shortcuts = {
      # Krohnkite navigation and layout controls.
      kwin.KrohnkiteDecrease = "Meta+[";
      kwin.KrohnkiteFloatAll = "Meta+Shift+F";
      kwin.KrohnkiteFocusDown = "Meta+J";
      kwin.KrohnkiteFocusLeft = "Meta+H";
      kwin.KrohnkiteFocusRight = "Meta+L";
      kwin.KrohnkiteFocusUp = "Meta+K";
      kwin.KrohnkiteGrowHeight = "Meta+Shift+J";
      kwin.KrohnkiteIncrease = "Meta+]";
      kwin.KrohnkiteMonocleLayout = "Meta+M";
      kwin.KrohnkiteNextLayout = "Meta+\\";
      kwin.KrohnkitePreviousLayout = "Meta+|";
      kwin.KrohnkiteShiftDown = "Meta+Ctrl+J";
      kwin.KrohnkiteShiftLeft = "Meta+Ctrl+H";
      kwin.KrohnkiteShiftRight = "Meta+Ctrl+L";
      kwin.KrohnkiteShiftUp = "Meta+Ctrl+K";
      kwin.KrohnkiteShrinkHeight = "Meta+Shift+K";
      kwin.KrohnkiteShrinkWidth = "Meta+Shift+H";
      kwin.KrohnkiteToggleFloat = "Meta+F";
      kwin.KrohnkitegrowWidth = "Meta+Shift+L";

      # Navigate the virtual desktop grid.
      kwin."Switch One Desktop Down" = "Meta+Down";
      kwin."Switch One Desktop Up" = "Meta+Up";
      kwin."Switch One Desktop to the Left" = "Meta+Left";
      kwin."Switch One Desktop to the Right" = "Meta+Right";
      kwin."Switch to Desktop 1" = [ "Meta+F1" "Ctrl+F1" ];
      kwin."Switch to Desktop 2" = [ "Meta+F2" "Ctrl+F2" ];
      kwin."Switch to Desktop 3" = [ "Meta+F3" "Ctrl+F3" ];
      kwin."Switch to Desktop 4" = [ "Meta+F4" "Ctrl+F4" ];

      # Move the active window through the virtual desktop grid.
      kwin."Window One Desktop Down" = [ "Meta+Ctrl+Down" "Meta+Ctrl+Shift+Down" ];
      kwin."Window One Desktop Up" = [ "Meta+Ctrl+Up" "Meta+Ctrl+Shift+Up" ];
      kwin."Window One Desktop to the Left" = [ "Meta+Ctrl+Left" "Meta+Ctrl+Shift+Left" ];
      kwin."Window One Desktop to the Right" = [ "Meta+Ctrl+Right" "Meta+Ctrl+Shift+Right" ];
    };

    configFile = {
      # Input and fonts.
      kcminputrc."Libinput/1739/0/Synaptics TM3276-022".NaturalScroll = true;
      kdeglobals.General.XftAntialias = true;
      kdeglobals.General.XftHintStyle = "hintfull";
      kdeglobals.General.XftSubPixel = "none";
      kdeglobals.General.fixed = "JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
      kdeglobals.General.font = "JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
      kdeglobals.General.menuFont = "JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
      kdeglobals.General.smallestReadableFont = "JetBrains Mono,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
      kdeglobals.General.toolBarFont = "JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
      kdeglobals.WM.activeFont = "JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";

      # KRunner behavior and enabled plugins.
      krunnerrc.General.FreeFloating = true;
      krunnerrc.Plugins.krunner_appstreamEnabled = false;
      krunnerrc.Plugins.krunner_katesessionsEnabled = false;
      krunnerrc.Plugins.krunner_konsoleprofilesEnabled = false;
      krunnerrc.Plugins.krunner_powerdevilEnabled = false;
      krunnerrc.Plugins.krunner_sessionsEnabled = false;
      krunnerrc."Plugins/Favorites".plugins =
        "krunner_sessions,krunner_powerdevil,krunner_services,krunner_systemsettings";

      # Nine desktops in a 3x3 grid. KWin maintains their internal IDs.
      kwinrc.Desktops.Number = 9;
      kwinrc.Desktops.Rows = 3;

      # KWin effects.
      kwinrc.Effect-blur.NoiseStrength = 0;
      kwinrc.Effect-overview.BorderActivate = 9;
      kwinrc.Effect-translucency.Inactive = 95;
      kwinrc.Effect-translucency.MoveResize = 100;
      kwinrc.Plugins.fadeEnabled = true;
      kwinrc.Plugins.krohnkiteEnabled = true;
      kwinrc.Plugins.kwin4_effect_geometry_changeEnabled = true;
      kwinrc.Plugins.scaleEnabled = false;
      kwinrc.Plugins.screenedgeEnabled = false;
      kwinrc.Plugins.translucencyEnabled = true;
      kwinrc.Plugins.wobblywindowsEnabled = true;

      # Krohnkite's active layout cycle and gaps.
      kwinrc.Script-krohnkite.binaryTreeLayoutOrder = 0;
      kwinrc.Script-krohnkite.cascadeLayoutOrder = 0;
      kwinrc.Script-krohnkite.columnsLayoutOrder = 0;
      kwinrc.Script-krohnkite.floatingLayoutOrder = 0;
      kwinrc.Script-krohnkite.monocleLayoutOrder = 4;
      kwinrc.Script-krohnkite.quarterLayoutOrder = 1;
      kwinrc.Script-krohnkite.screenGapBetween = 7;
      kwinrc.Script-krohnkite.screenGapBottom = 7;
      kwinrc.Script-krohnkite.screenGapLeft = 7;
      kwinrc.Script-krohnkite.screenGapRight = 7;
      kwinrc.Script-krohnkite.screenGapTop = 7;
      kwinrc.Script-krohnkite.spiralLayoutOrder = 3;
      kwinrc.Script-krohnkite.spreadLayoutOrder = 0;
      kwinrc.Script-krohnkite.stackedLayoutOrder = 0;
      kwinrc.Script-krohnkite.stairLayoutOrder = 0;
      kwinrc.Script-krohnkite.threeColumnLayoutOrder = 2;
      kwinrc.Script-krohnkite.tileLayoutOrder = 0;

      kwinrc.Windows.RollOverDesktops = true;
      kwinrc.Xwayland.Scale = 1.25;
      plasma-localerc.Formats.LANG = "en_US.UTF-8";
    };
  };
}
