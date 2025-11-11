{ ... }@inputs:
{
  homebrew.casks =
    builtins.map
      (cask: {
        name = cask;
        greedy = true;
      })
      [
        "nikitabobko/tap/aerospace"
        "aldente"
        "chatgpt-atlas"
        "clearvpn"
        "cursor"
        "discord"
        "docker-desktop"
        "ghostty"
        "google-chrome"
        "karabiner-elements"
        "keycastr"
        "notion"
        "obsidian"
        "raycast"
        "shottr"
        "tailscale-app"
        "todoist-app"
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
