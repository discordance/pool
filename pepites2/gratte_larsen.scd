(
Ndef(\z, {

	// get fed back signal and add a little noise to get things going
	var sig = Ndef(\z).ar + WhiteNoise.ar(0.001!2);
	var a, k, delfreq, minfreqs, freqs, dry;

	// delay due to distance from amp - I chose 0.05s, or 20Hz
	delfreq = 20;
	sig = DelayN.ar(sig,1/10-ControlDur.ir,1/delfreq-ControlDur.ir);

	// guitar string frequencies - for some reason I had to pitch them down
	// a few octaves to get a good sound.
	// open strings
	//// freqs = (64+[0,5,10,15,19,24]).midicps/8;
	// e minor
	freqs = (64+[0,7,12,15,19,24]).midicps/4;

	// whammy bar modulates freqs:
	minfreqs = freqs*0.5;
	freqs = freqs*MouseButton.kr(1,0.75,4);

	// 6 comb filters emulate the strings' resonances
	sig = CombN.ar(sig!6,1/minfreqs,1/freqs,8).mean;

	// a little filtering... mouse Y controls amp
	sig = LPF.ar(sig,8000);
	sig = HPF.ar(sig*MouseY.kr(0,5),80);

	// and some not too harsh distortion - mouse X controls damping
	sig = RLPFD.ar(sig,MouseX.kr(200,10000,1)*[1,1.1],0.1,0.5);
	sig = sig + sig.mean;

	// and finally a spot of reverb
	dry = sig;
	10.do {
		d = 0.2.rand;
		sig = AllpassN.ar(sig,d,d,5);
	};
	(dry + sig)*0.125;

}).play;
)

s.prepareForRecord;
s.record("test");
s.stop;