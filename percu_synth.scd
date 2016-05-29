SynthDef(\wood, {arg out=0, amp=0.3, pan=0, sustain=0.5, t_trig=1, freq=100, rq=0.06;
	var env, signal;
	var rho, theta, b1, b2;
	b1 = 2.0 * 0.97576 * cos(0.161447);
	b2 = 0.9757.squared.neg;
	signal = SOS.ar(K2A.ar(t_trig), 1.0, 0.0, 0.0, b1, b2);
	signal = Decay2.ar(signal, 0.4, 0.8, signal);
	signal = Limiter.ar(Resonz.ar(signal, freq, rq*0.5), 0.9);
	env = EnvGen.kr(Env.perc(0.00001, sustain, amp), doneAction:2);
	Out.ar(out, Pan2.ar(signal, pan)*env);
}).add;

SynthDef(\marimba, {arg out=0, amp=0.3, t_trig=1, sustain=0.5, gate=1, freq=100, rq=0.006;
	var env, signal;
	var rho, theta, b1, b2;
	env = EnvGen.kr(Env.adsr(0.0001, sustain, sustain/2, 0.3), gate, doneAction:2);
	b1 = 1.987 * 0.9889999999 * cos(0.09);
	b2 = 0.998057.neg;
	signal = SOS.ar(K2A.ar(t_trig), 0.3, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal*0.8, freq, rq) + DelayC.ar(RHPF.ar(signal*0.9, freq*0.99999, rq*0.999), 0.02, 0.01223);
	signal = Decay2.ar(signal, 0.4, 0.3, signal);
	Out.ar(out, (signal*env)*(amp*0.65)!2);
}).add;

SynthDef(\SOStom,
	{arg out = 0, sust = 0.4, drmLvl = 0.25,
		freq = 90, timbre = 1.0, amp = 0.8, totVol = 0.9;
		var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
		var stick_noise, stick_env;
		var drum_reson, tom_mix;

		drum_mode_env = EnvGen.ar(Env.perc(0.005, sust), 1.0, doneAction: 2);
		drum_mode_sin_1 = SinOscFB.ar(freq*0.8, 0.2, drum_mode_env * 0.5);
		drum_mode_sin_2 = SinOscFB.ar(freq, 0.2, drum_mode_env * 0.5);
		drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.9),
			freq*0.85,
			timbre/1.3,
			mul: drum_mode_env*5,
			add: 0);
		drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drmLvl;
		stick_noise = Crackle.ar(2.01, 1);
		stick_env = EnvGen.ar(Env.perc(0.005, 0.01 * 2.5 * sust), 1.0) * 3;
		tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp;
		tom_mix = tom_mix.clip2(1) * totVol;
		Out.ar(abc, tom_mix);
		Out.ar(out, [tom_mix, tom_mix])

	}
).add;

SynthDef(\SOSsnare,
	{arg out = 0, sust = 0.1, drmLvl = 0.25,
		snrLvl = 40, tight = 1000,totVol = 0.5,
		freq = 405, amp = 0.8;
		var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
		var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
		var snare_env;
		var snare_drum_mix;

		drum_mode_env = EnvGen.ar(Env.perc(0.005, sust), 1.0, doneAction: 2);
		drum_mode_sin_1 = SinOscFB.ar(freq*0.53, 0.5, drum_mode_env * 0.5);
		drum_mode_sin_2 = SinOscFB.ar(freq, 0.5, drum_mode_env * 0.5);
		drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
			184,
			0.5/1.3,
			mul: drum_mode_env*5,
			add: 0);
		drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drmLvl;

		// choose either noise source below
		//	snare_noise = Crackle.ar(1.2, 1);
		snare_noise = LFNoise0.ar(20000, 0.1);
		snare_env = EnvGen.ar(Env.perc(0.005, sust), 1.0, doneAction: 2);
		snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
		snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
		snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
		snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
		snare_reson = Resonz.ar(snare_brf_4, tight, mul: snrLvl) ;
		snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * amp;
		snare_drum_mix = snare_drum_mix.clip2(1) * totVol;
		Out.ar(abc, snare_drum_mix);
		Out.ar(out, [snare_drum_mix, snare_drum_mix]);

	}
).add;

SynthDef(\SOShats,
	{arg out = 0, freq = 6000, sust = 0.1, amp = 0.8, totVol = 0.5, rez = 1;
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
		initial_bpf_contour = Line.ar(15000, 9000, 0.1);
		initial_env = EnvGen.ar(Env.perc(0.005, sust), 1.0);
		initial_bpf = BPF.ar(root_cymbal, initial_bpf_contour, mul:initial_env,rq:rez);
		body_env = EnvGen.ar(Env.perc(0.005, sust, 1, -2), 1.0, doneAction: 2);
		body_hpf = BHiPass4.ar(in: root_cymbal, freq: Line.ar(9000, 12000, sust),mul: body_env, add: 0, rq: rez);
		cymbal_mix = Mix.new([initial_bpf, body_hpf]) * amp;
		cymbal_mix = cymbal_mix.softclip(1) * totVol;
		Out.ar(abc, cymbal_mix);
		Out.ar(out, [cymbal_mix, cymbal_mix])
}).add;


SynthDef("SOSkick",
	{ arg out = 0, freq = 50, modFrq = 3, modInd = 4, sust = 0.01, amp = 0.8, noiseL = 0.025, vol=0.25,rez=1;
		var pitch_contour, drum_osc, drum_lpf, drum_env;
		var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
		var kick_mix;
		pitch_contour = Line.ar(freq*2, freq, 0.02);
		drum_osc = PMOsc.ar(	pitch_contour,
			modFrq,
			modInd/1.3,
			mul: 1,
			add: 0);
		drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
		drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sust), 1.0, doneAction: 2);
		beater_source = WhiteNoise.ar(noiseL);
		beater_hpf = BHiPass4.ar(in: beater_source, freq: 500, mul: 1, add: 0, rq:rez);
		lpf_cutoff_contour = Line.ar(6000, 500, 0.03);
		beater_lpf = BLowPass4.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0, rq:rez);
		beater_env = beater_lpf * EnvGen.ar(Env.perc(0.005, sust), 1.0, doneAction: 2);
		kick_mix = Mix.new([drum_env, beater_env]) * amp;
		kick_mix = kick_mix.clip2(1) * vol;
		Out.ar(abc, kick_mix);
		Out.ar(0, [kick_mix, kick_mix])
	}
).add;


