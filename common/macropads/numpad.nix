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

      calc = setScene "Cows";
      mail = setScene "Vader";

      kp0 = setScene "Intermezzo";

      kp1 = setScene "Fullscreen Slides";
      kp2 = setScene "Slides + Closeup";
      kp3 = setScene "Closeup + Slides";
      kpplus = setScene "Lectern View";

      kp4 = setScene "Fullscreen Closeup";
      kp5 = setScene "Fullscreen Overview";
      kp6 = setScene "Fullscreen Audience";

      kp7 = setScene "Herald Closeup";
      kp8 = setScene "Herald Overview";

      kp9 = setScene "Audience + Slides";
      kpminus = setScene "Audience + Closeup";

      homepage = setScene "Break";

      # unused keys:
      # tab kpslash kpasterisk backspace space kpdot
    };
  };
}
