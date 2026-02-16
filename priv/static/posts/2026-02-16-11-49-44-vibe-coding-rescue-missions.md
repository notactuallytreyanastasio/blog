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
