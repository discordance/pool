

SynthDef(\snare_stein, { |out=0, amp=0.1, pan=0|
var snare, filtWhite;

filtWhite = LPF.ar(WhiteNoise.ar(1), 7040, 1);

snare = ((SinOsc.ar(330,0,0.25) * EnvGen.ar(Env.perc(0.0005,0.055)))
+(SinOsc.ar(185,0,0.25) * EnvGen.ar(Env.perc(0.0005,0.075)))
+(filtWhite * EnvGen.ar(Env.perc(0.0005,0.2), doneAction: 2) * 0.2)
+(HPF.ar(filtWhite, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.183)) * 0.2)
);

Out.ar(out, Pan2.ar(snare * amp * 10, pan));

},
metadata: (
	credit: "Snare written by Esben Stein, I believe",
	tags: [\percussion, \drum, \snare]
	)
).add;

Synth(\snare_stein, [\amp,0.1]);

SynthDef(\oneclap_thor, {arg out=0, t_trig=1, amp=0.1, filterfreq=100, rq=0.1, pan=0;
var env, signal, attack, noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	//noise = PinkNoise.ar(1)+SinOsc.ar([(filterfreq)*XLine.kr(1,0.01,3), (filterfreq+4)*XLine.kr(1,0.01,3) ], pi*0.5, XLine.kr(1,0.01,4));
	//signal = signal * SinOsc.ar(1,0.75);
	hpf1 = RLPF.ar(noise, filterfreq, rq);
	hpf2 = RHPF.ar(noise, filterfreq/2, rq/4);
	env = EnvGen.kr(Env.perc(0.003, 0.00035));
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	//signal = Decay2.ar(signal, 0.5);
	signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
	Out.ar(out, Pan2.ar(signal * amp, pan));
	DetectSilence.ar(signal, doneAction:2);
},
metadata: (
	credit: "published on the sc-users list 2009-01-08 by thor",
	tags: [\clap, \handclap]
	)
).add;
Synth(\oneclap_thor, [\amp,0.1]);

// a kick made using what radio folks would call a "chirp"
SynthDef(\kick_chrp, { |out=0, amp=0.1, pan=0|

var ampenv, pitchenv;

ampenv   = EnvGen.ar(Env.perc(0, 0.2, curve: 0), doneAction: 2);
pitchenv = EnvGen.ar(Env.perc(0, 0.1, curve: -20).exprange(0, 1000), doneAction: 0);

Out.ar(out, Pan2.ar(SinOsc.ar(pitchenv) * amp, pan))


},
metadata: (
	credit: "by dan stowell. public domain",
	tags: [\kick, \drum, \percussion, \chirp]
	)
).add;

Synth(\kick_chrp, [\amp,0.5]);




SynthDef("kick_oto309", {
	arg out=0, amp=0.1, pan=0;
	var env0, env1, env1m, son;

	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2;
	son = son.clip2(1);

	Out.ar(out, Pan2.ar(son * amp));
},
metadata: (
	credit: "from 08091500Acid309 by_otophilia",
	tags: [\kick, \drum, \percussion]
	)
).add;

Synth("kick_oto309",[\amp,0.5]);


SynthDef(\cymbal808_ryan, {
	arg out=0, baseFreq = 300, time = 250, amp=0.1;
	//var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	//var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
	var signal, pulseEnv;

	pulseEnv = EnvGen.ar(Env.new([1.0, 0.6], [time], [-0.5]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width:0.55)) * 0.9);
	signal = RLPF.ar(signal, 7000, 0.6);
 	signal = RHPF.ar(signal, 6800, 1.5);
	signal = RHPF.ar(signal, 6800, 1.5);
	signal = RHPF.ar(signal, 1200, 1.5);
	signal = signal + FreeVerb.ar(signal);
	signal = signal * EnvGen.ar(Env.new([0, 1, 0.4, 0, 0], [2, time, 50, 500], [0, -0.5, 0, -50]), timeScale:(1/1000), doneAction:2);
	signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
	OffsetOut.ar(out, signal*4*amp);
},
metadata: (
	credit: "Published on sc-users 2007-08-25 by Ryan Brown",
	tags: ['808', \hihat, \percussion, \cymbal]
	)
).add;

Synth("cymbal808_ryan");

SynthDef("snare_oto309", {
	arg out=0, amp=0.1, pan=0;
	var env0, env1, env2, env1m, oscs, noise, son;

	env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
	env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
	env1m = env1.midicps;
	env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m*1.2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

	noise = WhiteNoise.ar(0.2);
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
	noise = noise * env2;

	son = oscs + noise;
	son = son.clip2(1) * amp;

	Out.ar(out, Pan2.ar(son, pan));
},
metadata: (
	credit: "from 08091500Acid309 by_otophilia",
	tags: [\snare, \drum, \percussion]
	)
).add;

Synth("snare_oto309");

// cymbalic
Synth(\cymbalic_mcld);

SynthDef(\cymbalic_mcld, { |out=0, pan=0, amp=0.1|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	thwack = EnvGen.ar(Env.perc(0.001,0.001,1));

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	freqs  = {exprand(300, 20000)}.dup(100);

	res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;

	Out.ar(out, Pan2.ar(((res * 1) + (lodriver * 2) + thwack) * amp, pan));
},
metadata: (
	credit: "Based on the example at http://www.mcld.co.uk/cymbalsynthesis/ published 2008 by Dan Stowell",
	tags: [\percussion, \cymbal, \gong, \inharmonic, \additive, \subtractive]
	)
).add;






(
    SynthDef('fullkickdrum', {

    var subosc, subenv, suboutput, clickosc, clickenv, clickoutput;

    subosc = {SinOsc.ar(40)};
    subenv = {Line.ar(1, 0, 1, doneAction: 2)};

    clickosc = {LPF.ar(WhiteNoise.ar(1),1500)};
    clickenv = {Line.ar(1, 0, 0.02)};

    suboutput = (subosc * subenv);
    clickoutput = (clickosc * clickenv);

    Out.ar(0,
        Pan2.ar(suboutput + clickoutput, 0)
    )

}).add;
)

t = Synth('fullkickdrum');

(
SynthDef('openhat', {

    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.3)};

    hatoutput = (hatosc * hatenv);

    Out.ar(0,
    Pan2.ar(hatoutput, 0)
    )

}).add;

SynthDef('closedhat', {

    var hatosc, hatenv, hatnoise, hatoutput;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.1)};

    hatoutput = (hatosc * hatenv);

    Out.ar(0,
    Pan2.ar(hatoutput, 0)
    )

}).add;
)

o = Synth('openhat');
c = Synth('closedhat');

(
SynthDef('snaredrum', {
var drumosc, filterenv, volenv, drumoutput, snaposc, snapenv, fulloutput;

drumosc = {Pulse.ar(65)};
filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};
drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

snaposc = {BPF.ar(HPF.ar(WhiteNoise.ar(1),500),1500)};
snapenv = {Line.ar(1, 0, 0.2, doneAction: 0)};

fulloutput = (drumoutput * volenv) + (snaposc * snapenv);
//fulloutput = (drumoutput * volenv);

Out.ar(0,
Pan2.ar(fulloutput, 0)
)
}).add;
)

t = Synth('snaredrum');


(
SynthDef('clap', {

var claposc, clapenv, clapnoise, clapoutput;

clapnoise = {BPF.ar(LPF.ar(WhiteNoise.ar(1),7500),1500)};
clapenv = {Line.ar(1, 0, 0.6, doneAction: 2)};

clapoutput = {Mix.arFill(7,
{arg i;
EnvGen.ar(
Env.new(
[0,0,1,0],
[0.01 * i,0,0.04]
)
) * clapnoise * 0.5
}
)};

Out.ar(0,
Pan2.ar(clapoutput * clapenv, 0)
)

}).add;
)

t = Synth('clap');


// ELECTRIBE
(
SynthDef("tribe1", {
	|outBus = 0, midiFreq = 60, gate = 1.0, amp = 0.5, freqMult = 1,
	waveType = 0, modType = 0, modDepth = 0.0, modSpeed = 4.0, ampDecay = 0.1|

	var freq, output, modEnvGen, ampEnvGen, pitchMod, white, waveFreq;

	freq = midiFreq.midicps * freqMult;
	white = WhiteNoise.ar;
	modEnvGen = EnvGen.kr(Env.perc(0.0001, modSpeed.reciprocal, 1, -6), gate);
	pitchMod =
		Select.kr(modType,
			[
			LFSaw.ar(modSpeed), LFPulse.ar(modSpeed),
			LFTri.ar(modSpeed), Latch.ar(white, Impulse.ar(modSpeed)),
			white,
			white * modEnvGen, modEnvGen
			]
		);

	waveFreq = (freq * (1 + (pitchMod * modDepth))).clip(40, inf);

	output =
		Select.ar(waveType,
			[
			SinOsc.ar(waveFreq),
			LFTri.ar(waveFreq)
			]
		);

	ampEnvGen = EnvGen.kr(Env.perc(0.0001, ampDecay, 1, -6), gate);
	output = output * ampEnvGen * amp;

	Out.ar(outBus, output ! 2);
	}
).add;
)

t = Synth('tribe1');
[
\amp, ControlSpec(0.0, 1.0, \lin, 0.01, 0.5, "level"),
\freqMult, ControlSpec(0.25, 16.0, \exp, 0.01, 1.0, "mult"),
\waveType, ControlSpec(0, 1, \lin, 0.1, 0.0, "wave type"),
\modType, ControlSpec(0, 6, \lin, 0.1, 0.0, "mod type"),
\modDepth, ControlSpec(-1.0, 12.0, \lin, 0.001, 0.0, "mod depth"),
\modSpeed, ControlSpec(0.2, 120.0, \exp, 0.001, 4.0, "mod speed"),
\ampDecay, ControlSpec(0.05, 0.8, \exp, 0.0001, 0.1, "amp DK")
]


//----------------------BIG KICK SYNTH DEF-------------------
(
SynthDef(\BigKick, {
		|
			out = 0,				pitch = 60, 			pan = 0,
			amp = 1,				click = 1,				gate = 1,
			decay = 1,				pDecaySpeed = 0.5, 	pDecayDepth = 20,
			attack = 0.0005
		|

		//Local Vars
		var osc, oscPitchEnv, oscAmpEnv, oscPitchDecay;
		var noise, noiseampEnv;
		var output;

		//Osc
		oscPitchDecay = (attack + decay) * pDecaySpeed;
		oscPitchEnv = EnvGen.ar(Env.perc(0, oscPitchDecay, pDecayDepth, 0));
		oscAmpEnv = EnvGen.ar(Env.perc(attack, decay, amp, -4), doneAction:2);
		osc = SinOsc.ar((pitch + oscPitchEnv), mul: oscAmpEnv);

		//Noise
		noiseampEnv = EnvGen.ar(Env.perc(0.0005, 0.03, (amp * click) * 0.3, -4));
		noise = WhiteNoise.ar(mul: noiseampEnv);

		//Out
		output = Pan2.ar(osc + noise, pan);
		Out.ar(out, output);
}).add;
)

//Pumping up the delay and muting the click really accentuate the issue
x=Synth(\BigKick, [\click,1.0,\decay,0.5]);



(
SynthDef(\hat808, {|out=0, freq=230, hpf=6500, release=0.8, amp=1|
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 0.15));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,release),doneAction:2);
  sig = sig*env;
  Out.ar(out, Pan2.ar(sig*amp,0));
}).add;
)

t=Synth(\hat808);

// snare 909

(
SynthDef(\snare909,{ |out=0,mul=1,velocity=1|
	var excitation, membrane;

	excitation = LPF.ar(WhiteNoise.ar(1), 7040, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(0.0005,0.055),doneAction:0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(0.0005,0.075),doneAction:0) * 0.25)

		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(0.0005,0.4),doneAction:2) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.283),doneAction:0) * 0.2)

	) * mul;
	Out.ar(out, membrane!2)
}).add
)

Synth(\snare909,[\mul,0.5,\velocity, rrand(0.5, 1.0)]);



// SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles


// SOSdrums


// SOSkick -------
// http://www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
// increase mod_freq and mod_index for interesting electronic percussion
(
SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 3, mod_index = 3, sustain = 0.8, amp = 0.5, beater_noise_level = 0.015;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}
	).add
)
Synth(\SOSkick);



// SOSsnare -------
// http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp

(
SynthDef(\SOSsnare,
	{arg out = 0, sustain = 0.1, drum_mode_level = 0.25,
	snare_level = 40, snare_tightness = 1000,
	freq = 405, amp = 0.8;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	var snare_env;
	var snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
					184,
					0.5/1.3,
					mul: drum_mode_env*5,
					add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;

// choose either noise source below
//	snare_noise = Crackle.ar(2.01, 1);
	snare_noise = LFNoise0.ar(20000, 0.1);
	snare_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
	}
).add
)
Synth(\SOSsnare)



// SOShats -------
// http://www.soundonsound.com/sos/Jun02/articles/synthsecrets0602.asp

(
SynthDef(\SOShats,
	{arg out = 0, freq = 800, sustain = 0.9, amp = 0.2;
	var root_cymbal, root_cymbal_square, root_cymbal_pmosc;
	var initial_bpf_contour, initial_bpf, initial_env;
	var body_hpf, body_env;
	var cymbal_mix;

	root_cymbal_square = Pulse.ar(freq, 0.5, mul: 1);
	root_cymbal_pmosc = PMOsc.ar(root_cymbal_square,
					[freq*1.34, freq*2.405, freq*3.09, freq*1.309],
					[310/1.3, 26/0.5, 11/3.4, 0.72772],
					mul: 1,
					add: 0);
	root_cymbal = Mix.new(root_cymbal_pmosc);
	initial_bpf_contour = Line.kr(15000, 9000, 0.1);
	initial_env = EnvGen.ar(Env.perc(0.005, 0.1), 1.0);
	initial_bpf = BPF.ar(root_cymbal, initial_bpf_contour, mul:initial_env);
	body_env = EnvGen.ar(Env.perc(0.005, sustain, 1, -2), 1.0, doneAction: 2);
	body_hpf = HPF.ar(in: root_cymbal, freq: Line.kr(9000, 12000, sustain),mul: body_env, add: 0);
	cymbal_mix = Mix.new([initial_bpf, body_hpf]) * amp;
	Out.ar(out, [cymbal_mix, cymbal_mix])
	}).add
)

Synth(\SOShats)




// SOStom -------
// http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp

(
SynthDef(\SOStom,
	{arg out = 0, sustain = 0.3, drum_mode_level = 0.25,
	freq = 60, drum_timbre = 1.0, amp = 0.1;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var stick_noise, stick_env;
	var drum_reson, tom_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.8, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.9),
								freq*0.85,
								drum_timbre/1.3,
								mul: drum_mode_env*5,
								add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;
	stick_noise = Crackle.ar(2.01, 1);
	stick_env = EnvGen.ar(Env.perc(0.005, 0.01), 1.0) * 3;
	tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp;
	Out.ar(out, [tom_mix, tom_mix])
	}
).add
);

Synth(\SOStom);


(
SynthDef("kickDrum", { arg gate=0;

        var daNoise,daOsc,env1,env2,env3;
        env1=Env.perc(0.001,1,80,-20);
        env2=Env.perc(0.001,1,1,-8);
        env3=Env.perc(0.001,1,80,-8);
        daNoise=LPF.ar(WhiteNoise.ar(1),EnvGen.ar(env1,gate)+20);

        daOsc=LPF.ar(SinOsc.ar(EnvGen.ar(env3,gate)+20),800);
        //output

        Out.ar(0,Pan2.ar(
                                Mix.ar([daNoise,daOsc]),

                                0,
                                EnvGen.kr(env2,gate,doneAction: 2)

                        );

                  );

}).add;
)


Synth("kickDrum",[\gate,1]);


SynthDef(\kik, { |basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 0.9,
        decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
    var    fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
        env = EnvGen.ar(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
        sig = SinOsc.ar(fcurve, 0.5pi, preamp) * env * amp;
    Out.ar(out, sig ! 2)
}).add;

Synth("kik",[\decay1,0.1]);