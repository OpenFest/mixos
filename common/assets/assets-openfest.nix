{ ... }: {
  imports = [ ./asset-downloader.nix ];
  mixos.assets = [{
    url = "https://rnd.qtrp.org/test_videos/cows.mp4";
    sha256 = "sha256-k8TuQ3mudlfet7RPdgv/Z/l3joE8JVN21KvycpwzUbM=";
    name = "test_videos/cows.mp4";
  }];
}
