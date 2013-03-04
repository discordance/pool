/**
 * Nunja - Sample Processor
 **/
(
s = Server.local;
s.options.memSize = 655536;
~rawPath = '/Users/nunja/Documents/AudioLib/supercollider/raw';
~testFile = '/Users/nunja/Documents/AudioLib/supercollider/raw/bounce_nappe_kitsh.wav';

b = Buffer.read(s,~testFile, action: {
	b.postln;
});
)

// play buffer
(
SynthDef(\help_Buffer, { arg out = 0, bufnum;
	var sig,  in, amp, freq, hasFreq, gate, threshold;

	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum),rate: 0.35, startPos: Rand(0,(b.numFrames * 0.9).ceil));
	sig = sig + PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum),rate: 0.35/2, startPos: Rand(0,(b.numFrames * 0.9).ceil));
	//sig = sig + Warp1.ar(2, bufnum, windowSize: 0.1, pointer:Rand(0.1,0.9),freqScale: 2)*1;


	//threshold = 0.05; // change

	//in = LPF.ar(Mix.new(sig), LFNoise0.kr(10,4000,100).abs);
	//amp = Amplitude.kr(in, 0.25, 0.25) * 0.1;

	//# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.1, median: 7);
	//gate = Lag.kr(amp > threshold, 0.01);

	//sig =  sig + VarSaw.ar(freq, 0, 0.2, amp*hasFreq*gate);

	// uncomment (3 sines (octave lower, pitch and octave higher mixed into one signal (out))
	//sig = sig + Mix.new(SinOsc.ar(freq * [0.5,1], 0, 0.2 * amp*hasFreq*gate));
	sig = HPF.ar(sig, 1200);
	7.do({
		sig = AllpassC.ar(sig, 0.02, [0.02.rand,0.02.rand], 2);
	});

	sig = sig.scaleneg(0.3).tanh; // disto
	//sig = Compander.ar(sig,sig,0.5,1,10.9);
	//sig = sig + (0.1*DelayN.ar(sig, 0.6, 0.02));
	sig = sig * EnvGen.ar(Env.perc(0.01,8),doneAction:2);

	Out.ar(out, sig);
}).add;
)

s.prepareForRecord;
s.record;
s.stopRecording;

(
x = Synth("help_Buffer", [\bufnum, b, \out, 0]);
)

(
r  = Task.new ({
	32.do({ arg index;
		Synth("help_Buffer", [\bufnum, b]);
		index.postln;
		9.wait;
	},);
	s.stopRecording;
});

r.play;
)

// free all buffers
(
Buffer.freeAll;
)



/**
 * STORAGE
 */
/**
 * Random Env Gen
 */

Env.new(Array.rand(10, 0.0, 1.0).add(0.0), Array.exprand(9, 0.001, 1.0), curve:\sin).plot;
//Env.adsr(Rand(0,0.1),Rand(0.3,0.6), Rand(0,0.8), Rand(0,5)).plot;
