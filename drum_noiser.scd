s.queryAllNodes;

/**
 * Nunja - Live Drum Noiser
 **/
(

// DEFS
SynthDef(\nun_rev_a, {
	arg out = 0, t_trig;
	var s, z, y, vol;
	vol = [0.0,0.2].asSpec.map(In.kr(7).lag(0.1));

	s = In.ar(out,2);
	z = DelayN.ar(s, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	y = y*EnvGen.ar(Env.perc(0.01,15),t_trig);
	s = s+(vol*y);
	Out.ar(out,s);
}).add;

SynthDef(\nun_cymb_1, {|out=0, release=0.1, t_trig=1|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, vol;

	release = [0.08,1.5].asSpec.map(In.kr(6).lag(0.1));
	vol = [0.0,0.2].asSpec.map(In.kr(8).lag(0.1));

	locutoffenv = EnvGen.ar(Env.perc(0.25, 5),t_trig) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3),t_trig) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	freqs  = {exprand(900, 20000)}.dup(20);
	res    = Ringz.ar(lodriver + hidriver, freqs).mean.dup;
	res    = (res*0.3) + (PinkNoise.ar()*0.6) * EnvGen.kr(Env.perc(0, release), t_trig);
	Out.ar(out, res*vol);
}).add;

SynthDef(\nun_hat_1, {|out=0, freq=150, hpf=7000, release=0.1, amp=1, t_trig=1|
    var pulse, sig, env, freqs,
	clicks, hiNoise;

	release = [0.01,0.5].asSpec.map(In.kr(6).lag(0.1));
	amp = [0.0,1.0].asSpec.map(In.kr(8).lag(0.1));

    freqs = [freq, freq * 1.4471, freq * 1.617, freq * 1.9265, freq * 2.5028, freq * 2.6637];
    pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 0.15));
    sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
    env = EnvGen.kr(Env.perc(0, release), t_trig, doneAction: 0);

	clicks = BPF.ar(PinkNoise.ar(Decay.ar(sig, 0.001 * LFNoise1.ar(4).abs)), //decay time is modulated
			12000,
			0.9,
		25 * LFNoise1.ar(4).range(0, 1)//extreme amplification of glitches.

	).fold(-1, 1);

	hiNoise =
		BPF.ar
		(
			WhiteNoise.ar(Decay2.ar(LFNoise1.ar(8, 0.5, 0.5), 0.02, 0.1) * 0.05),
			TRand.ar(12000, 15000, sig),
			0.9
	)*0.4*EnvGen.kr(Env.perc(0.01,0.03));

	sig = (sig+(hiNoise+clicks))*env;
    Out.ar(out, Pan2.ar(sig * amp, 0)); // delay
}).add;



~source = Group.head(s);
~effect = Group.tail(s);

~hhSynth = Synth.head(~source,"nun_hat_1");
~cymbSynth = Synth.head(~source,"nun_cymb_1");
~reverb = Synth.head(~effect,"nun_rev_a");


)



/**
 * Midi
 */
(
//list connected ins:
MIDIClient.init;
MIDIClient.sources;
MIDIIn.connectAll;
)

(
MIDIIn.removeFuncFrom(\noteOn, ~noiser_noteOn);
MIDIIn.removeFuncFrom(\control, ~noiser_control);

~noiser_control = { arg src, chan, num, val;
	var bus = Bus.new('control',num,1,s);
	//"CC"+[chan,num,val].postln;
	bus.set(val/127);
};

~noiser_noteOn = { arg src, chan, num, vel;
	if(chan == 9, {

		//"NoteOn"+[chan,num,vel / 127].postln;
		// HH 1
		if(num == 42,{
			~hhSynth.set(\t_trig,1);
			~reverb.set(\t_trig,1);
		});
		// HH2
		if(num == 44,{
			~cymbSynth.set(\t_trig,1);
			~reverb.set(\t_trig,1);
		});
		// CYM
		if(num == 46,{

		});
		// SN
		if(num == 38,{

		});
	});
};

MIDIIn.addFuncTo(\noteOn, ~noiser_noteOn); // add
MIDIIn.addFuncTo(\control, ~noiser_control); // add
)

