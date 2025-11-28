{ ... }@inputs:
{
  homebrew.casks =
    builtins.map
      (cask: {
        name = cask;
        greedy = true;
      })
      [
        "aldente"
        "antigravity"
        "brave-browser"
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
}
