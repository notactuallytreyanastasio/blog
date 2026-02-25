tags: blog,coding,vibe-coding

# Vibe Coding Rescue Missions

With the hubub that has been going around for the past year of Vibe Coding™️ or so, there have been few people offering solutions to vibe coded code that makes it to production in any meaningful way.

It seems to be a simple reality that this code is going to make it to production, and you are going to have to work with it.
I tend to use the robot, but very much try to write high quality work that I'd turn in written myself, albeit much slower.
However, sometimes there are spikes or experiments or whatever else, and they graduate.

Today we are going to take a look at an absolute mess of a vibe coded codebase, and find a means to untangle the mess and rot, while telling a bit of a fun story about a project that I took up.

I hope this will actually be useful to some people in a professional capacity.
My goal here isn't to bemoan vibe coding.
It is simply to offer insights into how to deliver more reliable and maintainable software in a changing world.

With that said, let's paint a bit of a picture.

## Part 1: How did we even write all this shit? What is the mess?

### I Got A Receipt Printer (first one) and wanted it to print me things

I was at an ATProto meetup in Brooklyn and met [Henry Zoo](https://bsky.app/profile/henryzoo.com) and he had a receipt printer.
During the event, it was printing off all the @'s to him from Bluesky on the receipt printer.
I had kind of had an obsession with these things since the game boy camera, and I love using things in ways they were not intended to be.

I spoke to Henry a bit about his setup (he is a super nice guy, and you should check out his projects sometime. He maintained Babel for a long time. He has a lot of other just cool stuff going on in general) and he quickly let me know the basics and had a Github gist to share with the dead basics of getting set up.

Assuming there would be some hardware difficulty I bought the _exact_ same model as him: an Epson TM-M50 with bluetooth/wifi.

This was a great start, if I could have gotten the bluetooth or wifi to work.
I had to pick up a USB B cable.
At this point I was using my Macbook Pro from work, but decided it would be easier/smarter to just work with a raspberry pi I had laying around.
My wife tends to buy me 1-2 of them every year or so knowing that they all end up being used in weird little projects, so I just had the hardware there and figured why not give it something dedicated so I could have it always on.
My work laptop didn't offer a chance to do anything like that.

So, now I had a computer always attached to the thing.
I started with a pi zero.

My goal started off as something resembling Henry's.

My [blog code](https://github.com/notactuallytreyanastasio/blog) consumes the entire Bluesky firehose live.
So, since I was getting the entire network, I figured I'd start with printing any messages coming over it with @bobbby.online or #bobby to then print at my desk.
It was a Friday night I did this, and it ended up becoming a bit of a party.
I received a TON of messages that night (not just random ones from the hashtag either) [like this](https://bsky.app/profile/underwriter4hire.pro/post/3lxj6fra4c22p) and it was quite enjoyable.

Now, to do all this, I had to start off writing some code.

I didn't care about the code.

I had never interfaced with a receipt printer before.

I was working with a mac, then later a raspberry pi

### The Receipt Printer Gets a Camera (this is where we get bad code, I'm telling the story, if you want the tl;dr it was slop and cobbled together like shit and you can skip here to [the rewrite section](#rewrite))

The basic Bluesky printing worked. Messages came in over the firehose, got formatted, printed out on the little Epson.
Fun party trick on a Friday night.
But I wanted more.

I had a Raspberry Pi Zero sitting there already.
So, I just attached to the printer.
I ordered a cheap Pi camera module.
The idea was simple: if I can receive photos, I ought to be able to take them.
I just wanted to keep running with the experiment because why not?
I had already been up like 20 hours straight and at this point was just fiending for something to keep doing.

I had generally figured out dithering just using some off the shelf stuff from claude, and started getting decent quality pretty quickly.
It was definitely better than the old Game Boy Camera.
This all was pretty pleasing and I just kept fucking with it and buying new camera modules.
I ran into issues with dithering as a whole that others encountered and tweaked some things, and overall it got kind of stable.

It was at this point the project was still fun and not tedious.
Soon that changed.
I ended up awake for like almost 48 hours (lol) just rolling with the punches trying to make this work as my ideas grew.

### The 24-Hour Death March

The majority of the `photo_booth` codebase was written in one frantic session that began here now.
September 5-6, 2025.
At this point I had decided I was going to make it a "photo booth".
I arranged it in a shoebox and had the camera sticking out, the receipt printer hidden, and a slot where the photos came out in front next to the camera.
It looked pretty ridiculous.

The first commit was at 5:23 PM. A clean 153-line bash script.
It took 3 photos with different `rpicam-jpeg` settings, processed each through 3 lighting modes (lowlight, auto, bright) to produce 9 dithered images, and printed 3 photo strips with SHA-256 signatures.

It was fine.

It was cute.

It was the high point lol.

Ten minutes later: `8ec3c11 wip`. Already fixing paths. Something was already not working.

By 6:48 PM, the commit `4abee47` landed: "try adding a bunch of debugging stuff and a verbose mode." This single commit added **329 lines** to the script. It went from 153 lines to nearly 500, and most of the new code was debugging infrastructure. `VERBOSE_MODE`, `DEBUG_LOG`, `ERROR_LOG`, `SESSION_LOG`, and _functions to print debug output to the receipt printer itself_.

Cuz here's the thing about a Raspberry Pi Zero running headless with no SSH set up:

**The receipt printer was the only screen.**

There was no monitor.
No SSH, I'm a lazy piece of shit.
The only way to see what was happening was to print it.
So I built an entire debugging system that formatted debug logs as images and sent them to the printer.
Error alerts with exclamation mark borders.
Session dumps.
Processing logs.
The debugging system was now more code than the actual photo booth.

### The USB Cable From Hell

But the real chaos hadn't started yet.

The Pi Zero has one USB port.
The camera connects via the CSI ribbon cable, that's fine.
But the printer connects via USB.
So I plugged in the printer, and the camera worked, and the printer worked.

_Separately._

The printer detection commit (`a46765a`) looked reasonable: check for Epson on `lsusb`, verify `/dev/usb/lp0` exists, test print, three retries, five-second waits.

Classic robust design. _Ship it dawg_.

Three hours later: `d2687f2` - "only check printer at photo time.", a complete rewrite of the detection approach.
Why? Because you can't check the printer at startup if the camera is plugged in.

_They shared the USB bus, and something wasn't right._

Then came the revelation. Commit `06cd4f4`. The message is just: **"well"**.

The diff tells the whole story.

It added a "SWAP TO PRINTER NOW!" message with a 5-second countdown, and after printing: "PHOTOS PRINTED! You can now swap back to camera USB if needed" with a 3-second wait.

I was _physically swapping USB cables_ between the camera and printer for each photo session.

Take the photos, unplug the camera, plug in the printer, print, unplug the printer, plug the camera back in.

This was the architecture.

This was the design.

### Where Is imgprint.py? (A Saga in Four Commits)

The `imgprint.py` script was right there in the repo.
Finding it should have taken one line of path resolution.
It took four commits over an hour of increasingly desperate searching.

First attempt: `$PRINTER_LIB/scripts/imgprint.py` with a default path. Didn't work.

Second: auto-detect via `BASH_SOURCE[0]` and `dirname`. Still nothing.

Third: add `find ~ -name "imgprint.py"` as a last resort, along with printing `BASH_SOURCE[0]`, `dirname`, `pwd`, `SCRIPT_DIR`, `PHOTO_BOOTH_ROOT`, and `PRINTER_LIB` to the receipt printer for debugging. Still couldn't find it.

The fourth commit (`7584d14`): "fixup for root run." Gave up on all the clever path detection entirely.

I hardcoded `PHOTO_BOOTH_ROOT="/home/pi/photo_booth"`.

Then I added a simple existence check. Problem "solved."

This is what vibe coding does to path resolution.

Four commits of increasingly sophisticated auto-detection strategies, each one more broken than the last, ending with a hardcoded absolute path.

The entire path-detection saga existed because the script was running in different contexts due to the USB cable swapping.

### The 11 PM Side Quest

In the middle of all this photo booth chaos, at 11 PM on night one, a completely unrelated feature appeared: a receipt paper typewriter. Four commits in 15 minutes.

First: a full typewriter with raw terminal mode (`termios`/`tty`), per-character processing, real-time printing, word wrapping. 175 lines of careful input handling.

Twelve minutes later: `v2 typewriter`. Completely different approach, batch mode instead of character-by-character.

Three minutes after that: scrapped both approaches, ripped out `termios`/`tty`/`textwrap`, went to basic `input()` with per-line printing.

Then fixups. Then "longer lines" changing `max_chars` from 48 to 64.

The typewriter is genuinely its own little narrative. It works, it's useful, and it has absolutely nothing to do with the photo booth. It's a textbook vibe coding side quest: fun idea at 11 PM, four rapid iterations, ship it, move on.

### The Camera Reset Dance

After all the USB swapping, the camera started failing to initialize. Naturally.

Commit `baab37d` ("welp") added delays and increased timeouts. The next commit went nuclear: `modprobe -r` to unload the camera kernel modules (`bcm2835-v4l2`, `bcm2835-isp`), reload them, `pkill rpicam/libcamera` to kill stuck processes, 3-second init delay. But then it **decreased** the timeout back to 1000ms, contradicting the previous commit that increased it. The commit after that added conditionals because the `modprobe` approach failed without root access.

### The Great EV Settings Merry-Go-Round

The final saga. Four commits in 35 minutes, going in perfect circles.

1. `196528c` - "slim down the shots" - Only lowlight mode now, one strip instead of three.
2. `59e7785` - "try another" - Switch to auto processing mode.
3. `684de15` - "bright mode" - Nope, switch to bright mode.
4. `05271a8` - "attempt this again with new ev settings" - Crank EV to +2.0, add shutter speed overrides, switch back to lowlight.
5. `b4769e6` - "back tothe simpler one with one basic default setting" - Remove everything. Back to the exact same state as commit 1.

Five commits. Zero net change. The typo in "tothe" tells you everything about the mental state.

### The Final Tally

By the time it was over, the photo booth repo looked like this:

- **869 lines** of bash in `photo_booth.sh` (up from 153)
- **2,487 lines total** across 9 files (Python + Bash)
- **27 commits** in roughly 24 hours
- Commit messages include: "wip", "well", "welp", "moar debug", "moar error stuff", "fixups", "back tothe simpler one"
- Zero tests
- Hardcoded paths everywhere
- The receipt printer doubles as both the output device and the debugger
- Architecture requires physically swapping USB cables between camera and printer
- The Python scripts are embedded inline inside the bash script as heredocs

But you know what?

_It worked._

Not well, not reliably, not in a way anyone would want to maintain.

But it took photos, dithered them, and printed receipt-paper photo strips.

It went to a party.
People used it.
The whole thing was actually a hit.

This is the nature of vibe coded projects that make it to "production."

### They work just well enough, under just the right conditions, with just the right person babysitting them.

### And then six months later you want to add a feature.

---

## Rewrite

### The Problem With "It Works"

My cats broke my receipt printer.
I was pretty upset but not upset enough to shell out another $150.
Then, valentines day came and my wife got me a new one.
This was exciting.
It was a model that could print even faster.
Anyways, I figured I would try the original `photo_booth` repo and just fuckin' lol.
It was such a mess there was just no way I was going to reasonably get it working without creating more of a soupy bucket of shit.

So, I figured I'd just write a new one.

### What "From Scratch" Actually Means

The new project, `read_my_receipts`, started on February 18, 2026 with a [decision graph](https://notactuallytreyanastasio.github.io/deciduous) and a clear goal: build a receipt printer management suite that works on macOS, starting with text printing and growing from there.
The first thing that happened was not writing code.

It was making choices:

1. **GUI framework**:

I looked at 3 options.

- egui (simplest)
- iced (Elm-inspired, better for growing complexity)
- tauri (web-based, most flexible styling)
-
- The reasoning was captured: "better for growing complexity" -- because this time we knew it was going to grow.

2. **Printer communication**: Raw ESC/POS over USB vs. CUPS vs. both. Selected raw ESC/POS. This is interesting because the photo booth used CUPS via Python. The new version went lower-level for more control. The photo booth had taught us that CUPS sometimes fights you.

3. **Connection type**: USB now, Bluetooth later. Scope it. Don't try to do everything on day one.

4. **Architecture**: Three-layer design. GUI layer (iced), Printer layer (discovery, connection, models, status), Platform layer (macOS and Linux specific code with conditional compilation). Clean separation so you can swap the GUI or add Bluetooth without rewriting printer logic.

These four decisions took about 15 minutes. They were logged in the decision graph before a single line of Rust was written. This is the opposite of the photo booth, where the first commit was code and the architecture was whatever happened to emerge from 24 hours of panicked hacking.

### The New Version Has Problems Too

I want to be clear: the rewrite was not a clean, frictionless experience. It had its own struggles. The iced GUI framework had API changes between versions. The escpos crate's API didn't match its documentation. The first build failed. The first runtime panicked (a scrollable widget issue).

But the difference is what happened when things went wrong.

When the build failed in the new project, the response was: read the escpos crate source code to understand the actual API, read the nusb crate source code, fix the build errors. Two observations logged, one action, one outcome. When the photo booth had build problems, the response was: add more debug printing.

When image printing didn't work in the new project, there was a systematic investigation. The decision graph shows the journey: attempted to use the image crate's dithering, discovered Python/PIL was better for preprocessing, chose a hybrid approach, implemented it, discovered the escpos library resets printer state when printing images (clearing buffered text), redesigned the image pipeline with URL-based image fetching, discovered that 5.3 MB raw images overflow the printer's memory buffer, fixed it by resizing to 576px before sending. Each step tracked, each failure linked to the investigation that followed.

When image printing didn't work in the photo booth, the response was five commits of swapping between lowlight/auto/bright dithering modes with no understanding of why any of them looked bad, ending at the exact starting point.

### The Image Pipeline: A Side-by-Side

The contrast is sharpest in how each project handles the same problem: getting a photo to look good on thermal paper.

**photo_booth's approach** (`adaptive_dither.py`):
Three separate functions with hardcoded parameters. `dither_for_lowlight` uses gamma 0.5 and threshold 90. `dither_for_auto` uses gamma 0.9 and threshold 128. `dither_for_bright` uses gamma 1.3 and threshold 135. The developer tried all three modes in sequence across five commits, couldn't tell which one looked better, and gave up. The dithering code itself is fine -- Floyd-Steinberg is Floyd-Steinberg -- but there's no logic to choose which mode to use. A human has to pick, and the human was exhausted at 3 PM on day two.

**read_my_receipts' approach** (`image_proc.rs`):
One adaptive pipeline that _measures the image_ and decides for itself. After applying auto-levels (histogram stretch from 2nd to 98th percentile), it calculates the mean brightness. Dark images (mean < 90) get gentle contrast (1.1x) and aggressive gamma lift (1.5). Medium images get moderate settings. Normal/bright images get the original parameters. Then it applies an unsharp mask to preserve edge detail before dithering. The pipeline adapts to each photo. No human has to pick a mode.

Same problem. Same algorithm (Floyd-Steinberg). Same printer. But the second version encodes the _understanding_ of why different photos need different treatment, not just the treatments themselves.

### What the New Version Ended Up With

Four days of work (Feb 18-22, 2026) produced:

- **Rust + iced** GUI with desktop and kiosk modes
- **Direct USB communication** via raw ESC/POS (no CUPS dependency)
- **Markdown editor** with receipt-formatted preview (42-char width -- the actual usable width of the TM-T88VI, which we discovered was 42 chars not the spec's 48, and documented in the decision graph)
- **Adaptive thermal image processing**: auto-levels, contrast, gamma correction, unsharp mask, Floyd-Steinberg dithering -- all adaptive based on measured image brightness
- **Website message polling**: the receipt printer can poll a website for messages and print them automatically, with images
- **WiFi photo upload server**: an axum web server with a mobile upload page and iOS/Android captive portal detection, so you can take a photo on your iPhone and print it over WiFi
- **Kiosk mode** for a 3-inch Pi display (320x240)
- **Cross-compilation** Docker setup for building on macOS and deploying to aarch64 Pi
- **Persistent USB connections** via `Arc<Mutex<>>` to avoid macOS `kIOReturnExclusiveAccess` errors from rapid open/close cycles
- **43 tests** including thermal pipeline unit tests
- **99 tracked decision nodes** with full edge connections

The photo booth had ~2,500 lines of Python/Bash and zero tests. The new version has more features in structured, tested Rust with a tracked decision history.

### The Actual Lesson (Before We Get to the Rescue)

The lesson is **not** "vibe coding is bad, don't do it." The photo booth was a fun Friday night hack that went to a party and made people smile. It was the right approach for that moment.

The lesson is that vibe coded projects have a very specific failure mode: **they encode solutions without encoding understanding.** The photo booth code knows that `rpicam-jpeg --awb auto` takes an OK photo and that gamma 0.5 helps with low-light dithering. But it doesn't know _why_ those values work, or what to do when they don't, or how to adapt to different conditions. That knowledge lived in the developer's head during the 24-hour session, and it evaporated the moment they went to sleep.

The decision graph from the rewrite captures something different. Node 89: "5.3 MB raw image sent to printer -- escpos says OK but nothing prints. Printer memory overflow. Need to resize to 576px before sending." That's not just a fix. That's a **lesson** that anyone reading the graph can learn from. The photo booth's equivalent discovery -- that images need to be 576 pixels wide -- is buried somewhere in the dithering code with no explanation of why.

This matters when it's time to rescue the code. Which is what we're going to do next.

---

## Part 3 Preview: The Rescue

In Part 2, we'll look at what happens when you take the photo_booth codebase -- all 2,487 lines of USB-swapping, debug-by-printing, hardcoded-path chaos -- and try to make it work on new hardware with new requirements. We'll compare that experience with the "from scratch" approach. And we'll talk about practical strategies for untangling vibe coded code that has made it to production in your own work.

The spoiler is that neither approach is strictly better. The rewrite gave us a cleaner codebase, but it took four days instead of one night. The rescue of the original would have been faster in some ways but would have carried forward architectural decisions (like the USB swapping) that fundamentally limit what the system can do.

The real question isn't "rewrite or rescue?" -- it's "what do you need the code to become, and which path gets you there with the least grief?"
