

b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/freesound/chord/F#_chamber_choir_chord_o.wav", 0,-1);

(
SynthDef(\seamless, {|rate = 1, out = 0, buffer = 0|
	var percent, ftime = 0.15;
	var a_snd, a_aph, a_tr, a_env;
	var b_snd, b_aph, b_tr, b_env;
	var sig;
	var vol = 1;

	ftime = ftime/rate;
	percent = ftime/(BufFrames.kr(buffer)/s.sampleRate)*rate;
	a_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer)/2);
	b_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer)/2);
	b_aph = (b_aph+(BufFrames.kr(buffer)/2)).wrap(0,BufFrames.kr(buffer));

	a_tr = ((a_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
	b_tr = ((b_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
	a_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,-2),a_tr);
	b_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,-2),b_tr);

	a_snd = BufRd.ar(1, buffer, a_aph) * a_env * 0.7;
	b_snd = BufRd.ar(1, buffer, b_aph) * b_env * 0.7;
	sig = (a_snd+b_snd)!2;
	Out.ar(out,sig);
}).add;
)


(
Synth.new("seamless", [\buffer, 2, \rate, 1 ]);
)
