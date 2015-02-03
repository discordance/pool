// first, download a nice IR to try out! (or use one of your own)
// 44.1kHz
"curl -o /tmp/r1_ortf.wav http://www.openairlib.net/sites/default/files/auralization/data/audiolab/r1-nuclear-reactor-hall/stereo/r1_ortf.wav".unixCmd;
// 48kHz
"curl -o /tmp/r1_ortf-48k.wav http://www.openairlib.net/sites/default/files/auralization/data/audiolab/r1-nuclear-reactor-hall/stereo/r1_ortf-48k.wav".unixCmd;

Server.default.makeGui;

s.options.memSize = 65536;
s.boot; // server must be booted

 ~path   = "/tmp/r1_ortf-48k.wav";
//~path   = "/tmp/woodroom.wav";
~ezConv = EZConv(~path,4096*2);


// inspect
~ezConv.numChannels;
~ezConv.irSpectrum;

(
// A simple test.
x = play {
        var o = SinOsc.ar(300 ! 2) * Decay2.ar(Impulse.ar(0.5), 0.15, 0.75); // stereo source
	    ~ezConv.ar(o, leak: 2, mul: 0.5); // watch out for gain buildup when convolving.
    }
)
x.free;

(
/*
This example uses a mono source instead. EZConv will use all available
channels from the IR and wrap around when input channels < IR channels.
The "leak factor" has no effect on mono sources.
*/
x = play {
        var o = PinkNoise.ar(0.5) * Decay2.ar(Impulse.ar(0.5), 0.15, 0.75); // mono source
        ~ezConv.ar(o, mul: 0.5);
    }
)
x.free;

(
/*
A multichannel source. EZConv will use all available channels from the
IR and wrap around when IR channels < input channels, starting (again) from the first IR channel.
*/
x = play {
        var o = PinkNoise.ar(0.5!4) * Decay2.ar(Impulse.ar(0.5), 0.15, 0.75); // multichannel source
        ~ezConv.ar(o, leak: 0.1, mul: 0.5);
    }
)
x.free;
~ezConv.free; // free the convolution buffer(s)
~ezConv = nil;