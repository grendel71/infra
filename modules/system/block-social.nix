{ ... }:
let
  blockHosts = [
    # Twitter / X
    "twitter.com"
    "www.twitter.com"
    "x.com"
    "www.x.com"
    # Instagram
    "instagram.com"
    "www.instagram.com"
    # Facebook
    "facebook.com"
    "www.facebook.com"
    "fb.com"
    "www.fb.com"
    # TikTok
    "tiktok.com"
    "www.tiktok.com"
    # YouTube
    "youtube.com"
    "www.youtube.com"
    "youtu.be"
    "www.youtu.be"
    # Snapchat
    "snapchat.com"
    "www.snapchat.com"
    # Pinterest
    "pinterest.com"
    "www.pinterest.com"
    # Twitch
    "twitch.tv"
    "www.twitch.tv"
    # Bluesky
    "bsky.app"
    "www.bsky.app"
    "bsky.social"
    "www.bsky.social"
    # Tumblr
    "tumblr.com"
    "www.tumblr.com"
  ];
in
{
  networking.hosts = {
    "0.0.0.0" = blockHosts;
  };
}
