# nvm is optional and Zsh-only; Fish uses the Nix baseline runtime.
# Keep custom NVM_DIR values and avoid loading a default version implicitly.
export NVM_DIR="${NVM_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/nvm}"
nvm() {
  local script
  for script in "$NVM_DIR/nvm.sh" @brewNvm@; do
    [[ -s "$script" ]] || continue
    unfunction nvm
    source "$script" --no-use || return
    nvm "$@"
    return
  done
  print -u2 -- 'nvm: no installation found; Node uses the Nix runtime'
  return 127
}
