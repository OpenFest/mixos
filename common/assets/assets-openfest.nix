{ pkgs, ... }:
let
  ffmpegify = ''${pkgs.ffmpeg}/bin/ffmpeg -i "$inf" "$outf"'';
  inkscapify = ''
    ${pkgs.inkscape}/bin/inkscape "$inf" \
      --export-filename="$outf" \
      --export-width=$(( 1920 * 4 ))
  '';
in
{
  imports = [ ./asset-downloader.nix ];
  mixos.assets = [
    {
      url = "https://rnd.qtrp.org/test_videos/cows.mp4";
      sha256 = "sha256-k8TuQ3mudlfet7RPdgv/Z/l3joE8JVN21KvycpwzUbM=";
      name = "test_videos/cows.mp4";
    }
    # {
    #   url = "https://nc.openfest.org/shanovideo/Short%20eye%20with%20text.mp4";
    #   sha256 = "sha256-0zwZm3qXARmDsg5vViwRiQUcr6ZCvcXKffIzGWyU+Uk=";
    #   name = "intermezzo_begin.mp4";
    # }
    {
      url = "https://vasil.ludost.net/adverts.mkv";
      sha256 = "sha256-uOblUyjzCe0nKYKxwOmPMOI4/XNM4HJEDNLrXXE1SkQ=";
      name = "break_video.mkv";
    }
    {
      url = "https://rnd.qtrp.org/of_thankyou.png";
      sha256 = "sha256-nSNR5ttQqFgFFLDfwLVYOjSCq4kzst4GhTQvGxmrBRY=";
      name = "thank_you.png";
    }
    {
      url = "https://rnd.qtrp.org/of_dual.png";
      sha256 = "sha256-VG0WA3U+UUHBP7jXbb1RNo6ZcCzt+CWZBRf5Dxqj0pQ=";
      name = "frame_dual.png";
    }
    {
      url = "https://rnd.qtrp.org/of_banner.png";
      sha256 = "sha256-DZgQ/Z5YL+GIGdXx3J1N3nk3FER1JGC5avidEE78I2M=";
      name = "banner.png";
    }
    {
      url = "https://rnd.qtrp.org/of_logo.png";
      sha256 = "sha256-WOcS5+YRESBpQonKwk6XF1DvN9HcaxDUA+g8S5v5W4A=";
      name = "intermezzo.png";
    }
    # {
    #   url = "https://nc.openfest.org/shanovideo/Frames/Frame%201%20video.svg";
    #   # sha256 = "sha256-mOIrneNs9K8QECSfcICDqI3kkk2zlzDdRdhgeGHdR+Q=";
    #   sha256 = "sha256-vRfhIbQkj303le4SY66B5vkO+9eiKTjgj3rkItOGs7g=";
    #   name = "frame_projector.png";
    #   convert = inkscapify;
    # }
    {
      url = "https://archive.org/download/star-wars-the-imperial-march-darth-vaders-theme/star-wars-the-imperial-march-darth-vaders-theme.mp3";
      sha256 = "sha256-CB9iJI1ehQcxm9AX7FcEG6Uckn6t+h20Nj9NZXoV3/w=";
      name = "imperial_march.ogg";
      convert = ffmpegify;
    }
  ];
}
