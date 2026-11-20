{ lib, os, ... }:
{
  xdg.configFile.rex = {
    source = ./rex;
    recursive = true;
  };
}
// lib.optionalAttrs (os == "darwin") {
  targets.darwin.defaults."com.superlogical.rex" = {
    "Workspace.terminalFontName" = "Monaspace Krypton Var";
    "Workspace.terminalFontPointSize" = 13.0;
    "Workspace.terminalFontWeight" = 300.0;
    "Workspace.terminalUsesDisplayP3" = true;
    "Workspace.terminalCursorStyle" = "block";
    "Workspace.terminalCursorStyleForced" = false;
    "Workspace.terminalCursorBlinkIntervalMilliseconds" = 0;
    "Workspace.terminalCursorBlinkUsesCustomInterval" = false;
    "Workspace.terminalSmoothScrolling" = true;
  };
}
