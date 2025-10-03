{ pkgs, ... }:
let
  ffmpegify = ''${pkgs.ffmpeg}/bin/ffmpeg -i "$inf" "$outf"'';
  inkscapify = ''
    ${pkgs.inkscape}/bin/inkscape "$inf" \
      --export-filename="$outf" \
      --export-width=$(( 1920 * 4 ))
  '';
in {
  imports = [ ./asset-downloader.nix ];
  mixos.assets = [
    {
      url = "https://rnd.qtrp.org/test_videos/cows.mp4";
      sha256 = "sha256-k8TuQ3mudlfet7RPdgv/Z/l3joE8JVN21KvycpwzUbM=";
      name = "test_videos/cows.mp4";
    }
    {
      url = "https://nc.openfest.org/shanovideo/Short%20eye%20with%20text.mp4";
      sha256 = "sha256-0zwZm3qXARmDsg5vViwRiQUcr6ZCvcXKffIzGWyU+Uk=";
      name = "intermezzo_begin.mp4";
    }
    {
      url =
        "https://nc.openfest.org/shanovideo/Stream%20video%20for%20a%20loop.mp4";
      sha256 = "sha256-uUNaaWjO8XZQiEjxdzcKKBQrSVcm2hVsZzVs6kf/7aY=";
      name = "break_video.mp4";
    }
    {
      url = "https://nc.openfest.org/shanovideo/Thank%20you%2C%20bye.mp4";
      sha256 = "sha256-Ge+wL0xFSm7ADY7Z2Ftuk0wsz7ckQL4Ewr/DClYgmDs=";
      name = "thank_you.mp4";
    }
    {
      url = "https://nc.openfest.org/shanovideo/Frames/Frame%202%20videos.svg";
      sha256 = "sha256-0t6bZ5sheWQIRdM8DnEklMPJOmLoM00DcmAP7BcT43Q=";
      name = "frame_dual.png";
      convert = inkscapify;
    }
    {
      url = "https://nc.openfest.org/shanovideo/Frames/Banner.svg"; # FIXME
      sha256 = "sha256-I0XhjljhUpjf1DVQ7D6wGasi94R5Gw8gv9Y3uO/AGi8=";
      name = "banner.png";
      convert = inkscapify;
    }
    {
      url = "https://nc.openfest.org/shanovideo/eye.svg"; # FIXME
      sha256 = "sha256-orBpR/5qZdi1nLkfxaiGR+Ax/PmyY+TI7+yFYstHBck=";
      name = "intermezzo.png";
      convert = inkscapify;
    }
    {
      url =
        "https://nc.openfest.org/shanovideo/Frames/Frame%20projector.svg"; # FIXME
      sha256 = "sha256-ZppVcDrggihU0cx2YfiR7Jxhdmv7f0WltTeaNu++nI4=";
      name = "frame_projector.png";
      convert = inkscapify;
    }
    {
      url =
        "https://archive.org/download/star-wars-the-imperial-march-darth-vaders-theme/star-wars-the-imperial-march-darth-vaders-theme.mp3";
      sha256 = "sha256-CB9iJI1ehQcxm9AX7FcEG6Uckn6t+h20Nj9NZXoV3/w=";
      name = "imperial_march.ogg";
      convert = ffmpegify;
    }
  ];
}
