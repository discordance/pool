
MantissaMask // to test bitcrush
(
// autotune.
s = Server.local;
t = ([0, 1, 3, 4, 7, 11, 12] + 70).midicps;
b = Buffer(s, t.size, 1);

v = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/massacre/long3.wav");

// alloc and set the values
s.listSendMsg( b.allocMsg( b.setnMsg(0, t) ).postln );

{
        var index, in, out, f0, fdiff;
        var bufnum = b;
	    var vocsnd = PlayBuf.ar(2,v, BufRateScale.kr(v),1,0,1);
	    in = vocsnd;
        //in = Pulse.ar(MouseX.kr(t.minItem, t.maxItem)) * 0.1;
        f0 = Pitch.kr(in).at(0);
        index = IndexInBetween.kr(bufnum, f0);
        fdiff = index.frac * (Index.kr(bufnum, index + 1) - Index.kr(bufnum, index));
        out = PitchShift.ar(in, 0.1, 1 - (fdiff / f0), 0.01, 0.01) ! 2;
	/*
	out = FaustZitaRev1.ar(
		out,
		out,
		in_delay:30,
		lf_x:2000,
		low_rt60:8,
		mid_rt60:8,
		hf_damping:20000,
		eq1_freq:315,
		eq1_level:1,
		eq2_freq:1000,
		eq2_level:1,
		dry_wet_mix:1,
		level:0);
	*/
        //RLPF.ar(out, [2000, 5000], 0.3)
}.play;
)

b.free;




(
var scale, buffer, voc;
// make your scale (NOTE: array must have 12 slots since we are dealing with "chromatic" input)
scale = FloatArray[0, 0, 5, 5, 7, 7, 9, 10, 10]; // dorian scale
voc = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/massacre/long3.wav");

// convert the scale to a buffer
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });

play({
	var input, corrected, freq, hasFreq, autotune;
	var vocsnd = PlayBuf.ar(2,voc, BufRateScale.kr(voc),1,0,1);

	// can be anything (e.g. SoundIn)
	input = vocsnd;//Saw.ar(SinOsc.kr(0.3,0.5pi).range(440,880), mul:0.3);

	// grab the frequency of the input signal
	# freq, hasFreq = Pitch.kr(input).lag;

	// map our input signal's frequency to our scale using DegreeToKey
	autotune = DegreeToKey.kr(buffer.bufnum, freq.cpsmidi,12).midicps;

	// use PitchShift to autotune the original signal (adjust windowSize to make it snap quicker, put a Lag on pitchRatio to make it glide, etc.)
	corrected = PitchShift.ar(input,windowSize: 0.5,pitchRatio: (autotune/freq).lag);
})
);


