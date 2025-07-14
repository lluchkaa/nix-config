{ ... }@inputs: {
  homebrew.casks = builtins.map (cask: { name = cask; greedy = true; }) [
    "nikitabobko/tap/aerospace"
    "aldente"
    "clearvpn"
    "cursor"
    "discord"
    "docker"
    "ghostty"
    "google-chrome"
    "keycastr"
    "notion"
    "obsidian"
    "raycast"
    "shottr"
    "todoist"
    "tor-browser"
    "vial"
    "visual-studio-code"
    "vmware-fusion"

    "font-fira-code-nerd-font"
    "font-monaspace"
  ];

  homebrew.taps = [
    "nikitabobko/tap"
  ];
}
