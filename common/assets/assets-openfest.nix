{ ... }: {
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
      name = "frame_dual.svg";
      convert = "inkscape";
    }
    {
      url =
        "https://archive.org/download/star-wars-the-imperial-march-darth-vaders-theme/star-wars-the-imperial-march-darth-vaders-theme.mp3";
      sha256 = "sha256-CB9iJI1ehQcxm9AX7FcEG6Uckn6t+h20Nj9NZXoV3/w=";
      name = "imperial_march.ogg";
      convert = "ffmpeg";
    }
    # intermezzo.svg missing
    # frame_projector.svg missing

  ];
}
