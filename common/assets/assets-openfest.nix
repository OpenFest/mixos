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
      url = "https://rnd.qtrp.org/break.mp4";
      sha256 = "sha256-664vgGNB4FI3+zTcdGNtmq6AQyCC7Tl4QP55SjKYO8c=";
      name = "break_video.mp4";
    }
    {
      url = "https://nc.openfest.org/shanovideo/Thank%20you%2C%20bye.mp4";
      sha256 = "sha256-Ge+wL0xFSm7ADY7Z2Ftuk0wsz7ckQL4Ewr/DClYgmDs=";
      name = "thank_you.mp4";
    }
    {
      url = "https://nc.openfest.org/shanovideo/Frames/Stream%202%20videos.svg";
      sha256 = "sha256-7v22Vrr+ThuwNAaaO202WXulrL0POzJ7R6s3TBak5Vk=";
      name = "frame_dual.png";
      convert = inkscapify;
    }
    {
      url = "https://nc.openfest.org/shanovideo/Frames/Banner.svg";
      sha256 = "sha256-ylC4CvKi+DcdZTzIYBqG6XpYVlygbg8LsCnT7cqf4hw=";
      name = "banner.png";
      convert = inkscapify;
    }
    {
      url = "https://nc.openfest.org/shanovideo/Background%20s%20nadpis.png";
      sha256 = "sha256-lrjUgENiImT6x/pfTQTsau9LepIF6KVNrhWYLIhJJwQ=";
      name = "intermezzo.png";
      convert = inkscapify;
    }
    {
      url = "https://nc.openfest.org/shanovideo/Frames/Frame%201%20video.svg";
      sha256 = "sha256-mOIrneNs9K8QECSfcICDqI3kkk2zlzDdRdhgeGHdR+Q=";
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
