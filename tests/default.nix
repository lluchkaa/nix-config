{ pkgs, inputs }:
let
  tmuxModule = import ../modules/home/core/pkgs/tmux {
    inherit pkgs;
    inherit (pkgs) lib;
    config.programs.tmux.enable = true;
  };
  sessionizer = builtins.head (
    builtins.filter (
      package: package.name == "tmux-sessionizer"
    ) tmuxModule.config.content.home.packages
  );
in
assert import ./language-support.nix { inherit (pkgs) lib; };
assert import ./profiles.nix { inherit pkgs inputs; };
assert import ./node.nix { inherit (pkgs) lib; };
assert pkgs.lib.versions.major pkgs.nodejs_26.version == "26";
{
  coding-skills = import ./coding-skills.nix { inherit pkgs inputs; };
  architecture =
    pkgs.runCommand "configuration-architecture-checks"
      {
        nativeBuildInputs = [
          pkgs.neovim
          pkgs.python3
          pkgs.zsh
          pkgs.bash
          pkgs.coreutils
          pkgs.findutils
          sessionizer
        ];
      }
      ''
        export HOME="$TMPDIR/home"
        export NVIM_LOG_FILE="$TMPDIR/nvim.log"
        mkdir -p "$HOME"
        nvim --headless -u NONE -l ${./neovim.lua} ${../modules/home/core/pkgs/neovim/nvim/lua/lluchkaa/lazy/plugins/lsp.lua}
        python3 ${./project-sessions.py} ${../modules/home/core/pkgs/tmux/tmux-sessionizer} ${pkgs.tmux}/bin/tmux
        python3 ${./node-runtime.py} ${../modules/home/core/pkgs/node/nvm.zsh}
        touch "$out"
      '';
}
