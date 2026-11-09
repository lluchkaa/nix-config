{ pkgs }:
let
  sessionizer = builtins.head (import ../modules/home/core/pkgs/tmux { inherit pkgs; }).home.packages;
in
assert import ./language-support.nix { inherit (pkgs) lib; };
assert import ./node.nix { inherit (pkgs) lib; };
assert pkgs.lib.versions.major pkgs.nodejs_26.version == "26";
{
  coding-skills = import ./coding-skills.nix { inherit pkgs; };
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
