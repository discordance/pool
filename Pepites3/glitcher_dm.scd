(
fork{
	//---------Source Files---------
	~numOfPatterns = 16;
	~synthDefToUse = \bufPlay; //Change to \bufPlay2 to use stereo samples
	~rate = 0.09; //Rate of playback
	~source = [ // Create an array of your samples. ~media.samples points at my base sample directory and is defined in my startup file.
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/kick/808b/1.wav",
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/snar/a4snare10/1.wav",
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/hat2/classy/1.wav",
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/drm1/jp8c2/1.wav",
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/clap/gli1/gli1.wav",
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/clap/dubclap/1.wav",
		"/Users/nunja/Documents/AudioLib/supercollider/percussion_fuckup/cymb/ace1/2.wav"
	];
	Buffer.freeAll;
	~buffers = ~source.collect{|source| Buffer.read(s, source)};
	~patterns = ~numOfPatterns.collect{|val| Pbind(*[dur: Pn(1/val, val)])};
	~randPattern = Prand(~patterns, 1);
	~patterns = ~buffers.collect{|buf| Pbind(*[bufnum: buf]) <> ~randPattern};
	SynthDef(\bufPlay, {|out = 0, bufnum, rateScale = 1, amp = 1| Out.ar(out, PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rateScale, doneAction: 2) * amp!2);}).add;
	SynthDef(\bufPlay2, {|out = 0, bufnum, rateScale = 1, amp = 1| Out.ar(out, PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rateScale, doneAction: 2) * amp);}).add;
	s.sync;
	Ppar(~patterns, inf).play(TempoClock(~rate, 0), protoEvent: (instrument: ~synthDefToUse, amp: 0.25));  //Change to /bufPlay2 for stereo samples
};
)