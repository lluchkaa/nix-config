_: {
  homebrew.casks =
    map
      (cask: {
        name = cask;
        greedy = true;
      })
      [
        "brave-browser"
        "claude"
        "cursor"
        "datagrip"
        "discord"
        "docker-desktop"
        "ghostty"
        "google-chrome"
        "karabiner-elements"
        "keycastr"
        "nvidia-geforce-now"
        "obsidian"
        "raycast"
        "raspberry-pi-imager"
        "shottr"
        "tailscale-app"
        "todoist-app"
        # "tor-browser"
        "vial"
        "viber"
        "visual-studio-code"
      ];
}
