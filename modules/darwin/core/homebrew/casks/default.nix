_: {
  homebrew.casks =
    map
      (cask: {
        name = cask;
        greedy = true;
      })
      [
        "betterdisplay"
        "brave-browser"
        "claude"
        "datagrip"
        "discord"
        "docker-desktop"
        "ghostty"
        "google-chrome"
        "karabiner-elements"
        "keycastr"
        "nvidia-geforce-now"
        "obsidian"
        "postman"
        "raycast"
        "raspberry-pi-imager"
        "shottr"
        "tailscale-app"
        "todoist-app"
        "tor-browser"
        "vial"
        "viber"
        "visual-studio-code"
      ];
}
