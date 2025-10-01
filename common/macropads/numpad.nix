{ ... }: {
  imports = [ ./shanokeys.nix ];

  mixos.macro-keyboards.numpad = {
    mappings = let
      setScene = sceneName: {
        endpoint = "SetCurrentPreviewScene";
        params = { inherit sceneName; };
      };
      cut = { endpoint = "TriggerStudioModeTransition"; };
    in {
      # actual numpad layout:
      # homepage    tab         mail        calc
      # <numlock>   kpslash     kpasterisk  backspace
      # kp7         kp8         kp9         kpminus
      # kp4         kp5         kp6         kpplus
      # kp1         kp2         kp3
      # kp0         space       kpdot       kpenter

      kpenter = cut;

      kp0 = setScene "Intermezzo";
      kpdot = setScene "Cows";

      kp1 = setScene "Fullscreen slides";
      kp2 = setScene "Fullscreen closeup";
      kp3 = setScene "Fullscreen overview";
      kp4 = setScene "Slides + Lecturer";
      kp5 = setScene "Lecturer + Slides";
      # kp6 =
      kp7 = setScene "Fullscreen Audience";
      kp8 = setScene "Audience + Slides";
      kp9 = setScene "Audience + Closeup";

      # kpplus =

      kpminus = setScene "Break";
      kpdiv = setScene "Herald closeup";
      kpmul = setScene "Herald overview";
    };
  };
}
