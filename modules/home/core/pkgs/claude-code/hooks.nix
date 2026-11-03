{
  Notification = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "bash $HOME/.config/claude/hooks/notify.sh \"Claude Code\" \"Claude needs your attention\"";
        }
      ];
    }
  ];
  Stop = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "bash $HOME/.config/claude/hooks/notify.sh \"Claude Code\" \"Task completed\"";
        }
      ];
    }
  ];
}
