{ ... }:
{
  homebrew.casks =
    map
      (cask: {
        name = cask;
        greedy = true;
      })
      [
        "brave-browser"
        "cursor"
        "datagrip"
        "discord"
        "docker-desktop"
        "ghostty"
        "google-chrome"
        "karabiner-elements"
        "keycastr"
        "notion"
        "obsidian"
        "raycast"
        "raspberry-pi-imager"
        "shottr"
        "tailscale-app"
        "todoist-app"
        "tor-browser"
        "vial"
        "visual-studio-code"
      ];
}
