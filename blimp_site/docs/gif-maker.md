# /gif-maker is not ported, and why

Checked 2026-09-30, against production.

## It is broken in production today

`/gif-maker` (BlogWeb.GifMakerLive, "Concert GIF Maker", added 41fdece on
2026-02-24) takes a YouTube URL. Its first step is
`yt-dlp --dump-json --no-download --no-playlist <url>` inside the `app`
container. Run there by hand on a public video:

```
$ docker compose exec app sh -c 'cp /app/cookies.txt /tmp/c.txt; yt-dlp --cookies /tmp/c.txt --dump-json --no-download --no-playlist https://www.youtube.com/watch?v=jNQXAC9IVRw'
WARNING: [youtube] No supported JavaScript runtime could be found. Only deno is enabled by default ...
WARNING: [youtube] The provided YouTube account cookies are no longer valid. They have likely been rotated in the browser ...
ERROR: [youtube] jNQXAC9IVRw: Sign in to confirm you're not a bot. Use --cookies-from-browser or --cookies for the authentication.
exit 1
```

yt-dlp 2026.07.04, the cookies file from 2026-02-23. So every visitor who
pastes a URL gets "Failed to fetch video info. The video may be private or
unavailable." and nothing after that step has run. `gif_maker_jobs`,
`gif_maker_frames` and `gif_maker_gifs` in blog_prod hold 0 rows (jobs expire
after 2 hours, so that only covers the last two hours, but no step can
succeed anyway).

## It is not gifmaker.bobbby.online

`gifmaker.bobbby.online` is Caddy -> `nathan:4001`, the `nathan` compose
service, built from `/opt/nathan` (the nathan_for_us Phoenix app, "Framecut",
its own database `nathan_for_us_prod`). `/gif-maker` on the main site is the
blog app's own GifMakerLive. Two apps, two codebases, two databases.

## What it needs that Blimp does not have

The pipeline (Blog.GifMaker.Processor, YouTube, FrameExtractor, GifGenerator):

1. `yt-dlp --download-sections "*HH:MM:SS-HH:MM:SS" -f "bestvideo[height<=720]+bestaudio/best[height<=720]"`
   downloads up to three minutes of the video.
2. `ffmpeg -i segment.mp4 -vf fps=1 -q:v 2 frame_%04d.jpg`, one JPEG a second,
   stored as bytea in `gif_maker_frames`.
3. The visitor picks frames; `ffmpeg ... palettegen` then `paletteuse=dither=bayer`
   with an optional `drawtext` caption makes the GIF, stored as bytea in
   `gif_maker_gifs`.

Each step is a program run on the server. The three ways out that worked for
/collage-maker do not work here:

- **In the browser.** Steps 2 and 3 could be a `<video>`, a canvas and a GIF
  encoder in the page. Step 1 cannot: a page cannot read YouTube's video
  bytes (no CORS on googlevideo.com, and the stream URLs are what yt-dlp
  works to extract). Without step 1 there are no frames.
- **Shell out from Blimp.** The runtime has `fork` and `waitpid` and no
  `exec` (builtins.zig at 0cffc08), so it cannot run yt-dlp or ffmpeg. Adding
  one is a Blimp change, and the image (alpine:3.20) would also need
  `apk add ffmpeg`, Python and yt-dlp, and a JS runtime for yt-dlp's YouTube
  extractor. It would then fail exactly as Phoenix fails now.
- **Keep the processing in Phoenix.** Keeps Phoenix on for a feature that
  does not work.

## What would move it

This needs a decision about the product, not a port:

- Retire `/gif-maker`, perhaps redirecting it to gifmaker.bobbby.online
  (Framecut), which is the site's working video-to-GIF app. The three tables
  and Blog.GifMaker.* can then go.
- Or make it "upload a clip": the visitor's own video file, frames taken by
  a `<video>` and canvas in the page, the GIF encoded in the page (the way
  /collage-maker now works), with Blimp storing the result. That is a new
  feature with the old page's look, and it no longer takes YouTube links.
- Or keep YouTube: fresh cookies, deno in the app image, and a way to get
  past YouTube's bot check from a Hetzner address. That is Phoenix
  maintenance, and Blimp would still need `exec`.

Until one of those is chosen, `/gif-maker`, `/api/gif-maker/frames/:id` and
`/api/gif-maker/gifs/:id` stay on Phoenix (Caddy's fallback).
