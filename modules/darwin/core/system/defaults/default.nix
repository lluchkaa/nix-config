{ ... }@inputs: {
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;

      tilesize = 48;

      minimize-to-application = true;
      show-recents = false;
      static-only = true;
      mru-spaces = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;

      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";

      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };

    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 10;
      KeyRepeat = 2;

      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;

      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
    };

    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
      HideDesktop = true;
      StageManagerHideWidgets = true;
      GloballyEnabled = false;
    };

    menuExtraClock = {
      Show24Hour = true;
      ShowAMPM = false;
      ShowDayOfWeek = true;
      ShowDate = 1;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      disable-shadow = true;
    };

    loginwindow = {
      GuestEnabled = false;
      SHOWFULLNAME = false;
    };

    ActivityMonitor = {
      IconType = 2;
      SortColumn = "CPUUsage";
    };

    universalaccess = {
      closeViewScrollWheelToggle = true;
    };

    CustomUserPreferences = {
      "com.apple.Terminal" = {
        StringEncodings = [ 4 ]; # UTF-8 encoding (default is system dependent)
      };

      "com.apple.TextEdit" = {
        RichText = false;
      };

      "com.apple.Safari" = {
        IncludeInternalDebugMenu = true;
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
      };

      "com.apple.DiskUtility" = {
        DUDebugMenuEnabled = true;
        advanced-image-options = true;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
