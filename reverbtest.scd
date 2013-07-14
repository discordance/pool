
// ******************************
// Reverb Tests - James Surgenor
// ******************************

// Reverb Synth
(
SynthDef(\reverb, {|decayTime=5,inChan=7,outChan=0, outGain=1,lpFreq=10000|
	var in,out,lowPass,allpass,combs;

	// Get send from channel (defaults to In 7)
	in = In.ar(inChan,1);
	// LPF (defaults to 10kHz)
	in = LPF.ar(in,lpFreq,1);

	// Parallel Combs (6)
	combs = Mix.ar(CombC.ar(in,0.04,[0.0271,0.0341,0.0373,0.0411,0.0437,0.0479],[decayTime.rand,decayTime.rand,decayTime.rand,decayTime.rand,decayTime.rand,decayTime.rand,],0.633));

	// Series Allpass (4)
	4.do({combs = AllpassC.ar(combs,0.05,0.05.rand,decayTime.rand,0.75)});
	out = combs;
	Out.ar(outChan, ((out*0.5)*outGain)!2); // Make 'pseudo-stereo'
}).add;
)


// Test synth
(
// Randomly triggered synth to test reverb
SynthDef(\testSynth,{|freq=440,sendAmp=0.5,sendChan=7,dur=1|
	var env,out;

	// Perc Env
	env = EnvGen.kr(Env.perc(0.01,0.1,1,-4),LFNoise0.kr(1,1),1,0,dur,0);

	out = SinOsc.ar(freq);
	out = out * env;

	// Send to effect
	Out.ar(sendChan,out*sendAmp);

	// Send to main out
	Out.ar(0,(out*0.5)!2); // Make 'pseudo-stereo'
}).add;
)


// Test everything - synth is randomly triggered, so wait
(
a = Synth(\testSynth);
b = Synth(\reverb,addAction:'addToTail');

r = Routine({
	inf.do({
		a.set(\freq,rrand(100,400));
		2.wait;
	})
}).play;
)


// Stop everything
(
r.stop;
a.free;
b.free;
)