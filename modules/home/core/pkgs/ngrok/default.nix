{ ... }@inputs: {
  xdg.configFile = {
    "ngrok/ngrok.yml".source = builtins.readFile ./ngrok.yml;
  };
}
