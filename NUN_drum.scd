/******************************************
 * Nunja Drum Machine - Supercollider
 *
 * Internal Audio Allowed Bus Range
 * 32 .. 62
 * Internal Control Allowed Bus Range
 * 32 .. 232
 * WARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNING
 * WARNING -> for compo all drumc and drumc bus desactivated
 */



~load_drum_engine.value();
~load_drum_gui.value();
~load_drum_midi.value();

(
~mainOut = 0;

~load_drum_midi =
{
	// midi connect all
	MIDIClient.init;
	//MIDIClient.sources;
	MIDIIn.connect(0,MIDIClient.sources.at(4));

	MIDIIn.removeFuncFrom(\noteOn, ~drum_noteOn);
    MIDIIn.removeFuncFrom(\control, ~drum_control);
	~last_t = 0;

	~drum_control = { arg src, chan, num, val;
	};

	~drum_noteOn = { arg src, chan, num, vel;
		var rate;
		(Main.elapsedTime - ~last_t).postln;
		~last_t = Main.elapsedTime;
		rate = (num/127);
		/* CHANNEL WAY
		*
		    if(chan == 0,{
			//Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0019+(rate*0.0025),\lo,0.8,\ts,0.35,\at,0.005]);
				//Synth.head(~drum_source,"nun_kick_a",[\vel,vel/127]);
			   Synth.head(~drum_source,"nun_hat_b",[\vel,vel/127]);
			});
			// drum
			if(chan == 1,{
				//Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0018-(rate*0.0025),\lo,0.8,\ts,0.3,\at,0.005]);
			});
			// drum
			if(chan == 2,{
				//Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.002-(rate*0.0025),\lo,0.99,\ts,0.35,\at,0.01]);
			});
			// drum
			if(chan == 3,{
				//Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0035-(rate*0.0025),\lo,1.0,\ts,0.27,\at,0.01]);
			   // Synth.head(~drum_source,"nun_cymb_b",[\vel,vel/127]);
			});
		*/
		/* PITCH WAY DRUM C WAY
		*
		if(chan == 9, {

			// drum way
			// drum
			if(num == 36,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0025,\lo,2,\ts,0.4,\at,0.005]);
				//Synth.head(~drum_source,"nun_kick_a",[\vel,vel/127]);
			});
			// drum
			if(num == 41,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0028,\lo,1.2,\ts,0.3,\at,0.005]);
			});
			// drum
			if(num == 43,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.006,\lo,0.99,\ts,0.35,\at,0.01]);
			});
			// drum
			if(num == 38,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0035,\lo,1.5,\ts,0.38,\at,0.01]);
			});
			// drum
			if(num == 39,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0045,\lo,1.2,\ts,0.2,\at,0.005]);
			});
			// drum
			if(num == 42,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0043,\lo,1.2,\ts,0.18,\at,0.005]);
			});
			// drum
			if(num == 44,{
				//Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0033,\lo,1.5,\ts,0.3,\at,0.005]);
				Synth.head(~drum_source,"nun_cymb_a",[\vel,vel/127]);
			});
			// drum
			if(num == 46,{
				//Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127,\te,0.0055,\lo,1.1,\ts,0.15,\at,0.01]);
				Synth.head(~drum_source,"nun_hat_a",[\vel,vel/127]);
			});
		    */

			// normal way
		if(chan == 9, {
			// kick
			if(num == 36,{
				Synth.head(~drum_source,"nun_kick_a",[\vel,vel/127]);
			});
			// drm1
			if(num == 41,{
				Synth.head(~drum_source,"nun_drum_b",[\vel,vel/127]);
			});
			// drm2
			if(num == 43,{
				Synth.head(~drum_source,"nun_drum_c",[\vel,vel/127]);
			});
			// sn
			if(num == 38,{
				Synth.head(~drum_source,"nun_snare_a",[\vel,vel/127]);
			});
			// cl
			if(num == 39,{
				Synth.head(~drum_source,"nun_clap",[\vel,vel/127]);
			});
			// hh1
			if(num == 42,{
				Synth.head(~drum_source,"nun_hat_b",[\vel,vel/127]);
			});
			// hh1
			if(num == 44,{
				Synth.head(~drum_source,"nun_cymb_a",[\vel,vel/127]);
			});
			// hh1
			if(num == 46,{
				Synth.head(~drum_source,"nun_hat_a",[\vel,vel/127]);
			});

		});
	};

MIDIIn.addFuncTo(\noteOn, ~drum_noteOn); // add
MIDIIn.addFuncTo(\control, ~drum_control); // add


};


~load_drum_engine = { {
/******************************************
 * KICK and Bass Drums
 */
/******************************************
 * HARD KICK A
 */
SynthDef(\nun_kick_a,{
	arg out = 32,
	vel = 1,
	basefreq = 50,
	ratio = 7,
	sweeptime = 0.05,
	preamp = 0.8,
	amp = 0.75,
	dist = 0,
	decay1 = 0.3,
    freq = 20000,
	mover = 0;

	//vars
    var fcurve, env, sig, dist_sig, d_lfo;
	// busses
	decay1 = In.kr(32).lag(0.05);
	basefreq = In.kr(33).lag(0.05);
	sweeptime = In.kr(34).lag(0.05);
	ratio = In.kr(35).lag(0.05);
	dist = In.kr(36).lag(0.05);
	freq = In.kr(37).lag(0.05);
	mover = In.kr(38).lag(0.05);
	// dsp
	d_lfo = LFNoise2.kr(20).range(0,0.5) * mover;

	basefreq = LFNoise2.kr(50).exprange(basefreq-2,basefreq+2);
	fcurve = EnvGen.ar( Env.perc(0,sweeptime).exprange(basefreq,basefreq*ratio));
    env = EnvGen.ar( Env.perc(0,decay1+d_lfo,1,-2), doneAction: 2);
	sig = SinOsc.ar(fcurve, 0.5pi, preamp);
	// distortion
	dist_sig =
		sig
		+ (LPF.ar(InsideOut.ar(sig,0.1+d_lfo)*LFNoise2.kr(20).range(0,0.07), LFNoise2.kr(90).exprange(150,3000)))
		+ (sig.scaleneg(LFNoise2.kr(20).range(-2,0))*0.2);

	sig = SelectX.ar(dist * 2, [sig, dist_sig] );
	sig = sig * env * amp * vel;
    // filter quirked
	freq = LFNoise2.kr(80).exprange(freq-100,freq+100).clip(20,20000);
	sig = RLPF.ar(sig, freq, 1);
    Out.ar(out, sig );
}).add;

/******************************************
 * HARD KICK B
 */
SynthDef(\nun_kick_b,{
	arg out = 33, vel = 1, amp=0.5, pan=0,
	click_rate = 110, shp1 = 50, shp2 = 20, freq = 20000, decay = 0.26, noise = 0;
	var env0, env1, env1m, sig, noise_sig;

	// busses
	decay = In.kr(42).lag(0.05);
	shp1 = In.kr(43).lag(0.05);
	shp2 = In.kr(44).lag(0.05);
	click_rate = In.kr(45).lag(0.05);
	noise = In.kr(46).lag(0.05);
	freq = In.kr(47).lag(0.05);

	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, decay], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([click_rate, shp1, shp2], [0.01, 0.29], [-4, -5]));
	env1m = env1.midicps;

	noise_sig = (env0*noise*RLPF.ar(LatoocarfianN.ar(c:LFNoise2.kr(0.1,0.5,1.5),d:LFNoise2.kr(0.1,0.5,1.5)), LFNoise2.kr(0.1).exprange(90,140), 0.9)).scaleneg(0.3);
	sig = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0)+noise_sig;
	sig = sig + SinOsc.ar(env1m, 0.5, env0);

	sig = sig * 1.2;
	sig = sig.clip2(1);
	freq = LFNoise2.kr(80).exprange(freq-100,freq+100).clip(20,20000);
	sig = RLPF.ar(sig, freq, 1);
	sig = sig * amp * vel;
	Out.ar(out, sig);
}).add;

/******************************************
 * SOFT KICK
 */
SynthDef(\nun_kick_c,{
	arg out = 34,
	vel = 1,
	freq = 50,
	mod_freq = 3,
	mod_index = 3,
	sustain = 0.8,
	amp = 0.5,
	filter_freq = 12000,
	distortion = 0,
	beater_noise_level = 1;

	var drum_osc, drum_lpf, fcurve, drum_env, beater, mix;

	// busses
	sustain = In.kr(52).lag(0.05);
	freq = In.kr(53).lag(0.05);
	mod_freq = In.kr(54).lag(0.05);
	filter_freq = In.kr(55).lag(0.05);
	distortion = In.kr(56).lag(0.05);

	fcurve = EnvGen.ar( Env.perc(0,0.01).exprange(freq,freq*30));
	beater_noise_level = LFNoise1.kr(2).range(0.015,0.025);
	sustain = sustain + LFNoise2.kr(0.6).range(-0.01,0.01);

	drum_osc = PMOsc.ar( fcurve,
			    mod_freq+LFNoise1.kr(100).range(-0.2,0.2),
				mod_index/1.3+LFNoise1.kr(90).range(-0.2,0.2),
				mul: 1,
				add: 0);

	drum_lpf = LPF.ar(in: drum_osc, freq: 8000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.01, sustain), 1.0, doneAction: 2);

	beater = LPF.ar(WhiteNoise.ar(beater_noise_level),Line.ar(freq*20, freq, 0.1),1.5);
	beater = beater * EnvGen.ar(Env.perc(0.001,0.1));
	mix = beater+drum_env;
	mix = DFM1.ar(mix, filter_freq, 0.1, 1+distortion, 0)*amp*vel;
	Out.ar(out, mix);

}).add;

/******************************************
 * DRUM A
 */
SynthDef("nun_drum_a", {
	|out = 35, vel = 1, midiFreq = 60, gate = 1.0, amp = 0.5, freqMult = 1,
	waveType = 0, modType = 0, modDepth = 0.0, modSpeed = 4.0, ampDecay = 0.1|

	var freq, output, modEnvGen, ampEnvGen, pitchMod, white, waveFreq;
	// busses
	ampDecay = In.kr(62).lag(0.05);
	midiFreq = In.kr(63).lag(0.05).cpsmidi;
	waveType = In.kr(64).lag(0.05);
	modType = In.kr(65).lag(0.05);
	modDepth = In.kr(66).lag(0.05);
	modSpeed = In.kr(67).lag(0.05);

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

	ampEnvGen = EnvGen.kr(Env.perc(0.0001, ampDecay, 1, -6), gate, doneAction:2);
	output = tanh(output) * ampEnvGen * amp * vel;

	Out.ar(out, output);
	}
).add;

/******************************************
 * DRUM B
 */
SynthDef("nun_drum_b", {
	arg out = 36, vel = 1, sustain = 0.6, drum_mode_level = 0.25,
	freq = 60, drum_timbre = 1.0, amp = 0.1;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var stick_noise, stick_env;
	var drum_reson, tom_mix;
	// busses
	sustain = In.kr(72).lag(0.05);
	freq = In.kr(73).lag(0.05).cpsmidi;
	drum_mode_level = In.kr(74).lag(0.05);
	drum_timbre = In.kr(75).lag(0.05);

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
	stick_env = EnvGen.ar(Env.perc(0.008, 0.01), 1.0) * 3;
	tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp * vel;
	Out.ar(out, tom_mix)
}).add;

/******************************************
 * SNARE A
 */
SynthDef("nun_snare_a", {
	arg out = 38, vel = 1, amp = 0.7, decay, freq1, freq2, filt, dist;
	var env0, env1, env2, env1m, oscs, noise, dist_sig, sig, amCoef;
	var lf1, lf2;
	lf1 = LFNoise2.kr(40).range(-0.05,0.05);
	lf2 = LFNoise2.kr(12).range(-0.1,0.1);
	// busses
	decay = In.kr(82).lag(0.05);
	freq1 = In.kr(83).lag(0.05).cpsmidi;
	freq2 = In.kr(84).lag(0.05).cpsmidi;
	filt = In.kr(85).lag(0.05);
	filt = filt + (lf1*filt);
	dist = In.kr(86).lag(0.05);
	dist = dist+(lf2*dist);

	env0 = EnvGen.ar(Env.new([0.9, 1, 0.5, 0], [0.001, 0.01, 0.03], [-2, -2, -2]));
	env1 = EnvGen.ar(Env.new([110, freq2, freq1], [0.001, 0.1], [-4, -5]));
	env1m = env1.midicps;
		env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, decay+(decay*lf2)], [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m+(env1m*lf1), 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 2, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m*2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0) + Impulse.ar(1);

	noise = PinkNoise.ar(0.2);
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 7000, 0.6, 3) + noise;
	noise = noise * env2;

	sig = (oscs + noise)*0.6;
	amCoef = 2*0.99/(1-0.99);
	dist_sig = MidEQ.ar(LPF.ar((1+amCoef)*sig/(1+(amCoef*sig.abs)), 8000), 900, 0.7, 8);
	dist_sig = dist_sig*EnvGen.ar(Env.perc(0.0005,decay+0.05), doneAction: 2) * 0.5;
	sig = SelectX.ar(dist * 2, [sig, dist_sig] ) * amp * vel;
	sig = DFM1.ar(sig,filt);
	Out.ar(out, sig);
}).add;

/******************************************
 * SNARE B
 */
SynthDef("nun_snare_b", {
	arg out = 39, vel = 1, sustain = 0.1, drum_mode_level = 0.25,
	snare_level = 40, snare_tightness = 1000,
	freq = 405, amp = 0.2;

	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	var snare_env;
	var snare_drum_mix;

	// busses
	sustain = In.kr(92).lag(0.05);
	freq = In.kr(93).lag(0.05) + LFNoise2.kr(5).range(-5,5);
	snare_tightness = In.kr(94).lag(0.05);
	drum_mode_level = In.kr(95).lag(0.05);
	snare_level = In.kr(96).lag(0.05);

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
	snare_noise = BPF.ar(WhiteNoise.ar(),3000);
	//snare_noise = LFNoise0.ar(20000, 0.1);
	snare_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp * vel;
	snare_drum_mix = CompanderD.ar(snare_drum_mix, thresh: -30.dbamp, slopeBelow: 1, slopeAbove: 0.15, clampTime: 0.003, relaxTime: 0.08);
	snare_drum_mix = (snare_drum_mix * (16.dbamp));
	Out.ar(out, snare_drum_mix)
}).add;

/******************************************
 * DRUM C
 */
SynthDef("nun_drum_c", {
	arg out = 37 ,
		vel = 1,
		amp=0.05,
		te=0.003,
		lo=1,
		ts=0.4,
		aT=0.005,
		sn=0, filtFreq=30, vol=1;
	var excitation, tension, loss, brane;
    // busses
	te = In.kr(102).lag(0.05);
	lo = In.kr(103).lag(0.05);
	ts = In.kr(104).lag(0.05);
	aT = In.kr(105).lag(0.05);
	filtFreq = In.kr(106).lag(0.05);

	excitation = EnvGen.kr(Env.perc(aT),1,timeScale: ts, doneAction: 0) * PinkNoise.ar(0.4);
	tension = te;
	loss = lo;
	brane = HPF.ar(MembraneHexagon.ar(excitation, tension, loss), filtFreq)*amp*EnvGen.ar(Env.perc(aT),timeScale: ts*2, doneAction: 2);
	brane = CompanderD.ar(brane, thresh: -25.dbamp, slopeBelow: 1, slopeAbove: 0.15, clampTime: 0.003, relaxTime: 0.08);
	brane = (brane * (16.dbamp)) * vel;
    Out.ar(out, brane);
}).add;

/******************************************
 * CLAP
 */
SynthDef("nun_clap", {
	arg out = 40, vel = 1, amp = 0.5, sustain = 0.2, filt;
	var env1, env2, output, noise1, noise2, lf1;
	// busses
	sustain = In.kr(112).lag(0.05);
	filt = In.kr(113).lag(0.05);

	lf1 = LFNoise0.kr(3).range(-0.005, 0.006);

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.003, 0.013+lf1, 0, 0.02, 0, 0.013+lf1, 0, 0.08+lf1], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, sustain], [0, -4]), doneAction:2);

	noise1 = BrownNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = BrownNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	output = noise1 + noise2;
	output = output * 10;
	output = output.softclip * amp * vel;
	Out.ar(out, MoogFF.ar(output,filt));

}).add;

/******************************************
 * HIHATS A
 */
SynthDef("nun_hat_a", {
	arg out = 41, vel = 1, decay = 0.3, freq = 6000, lf_rate, lf_depth;
	var hatosc, hatenv, hatnoise, hatoutput, lfo;

	// busses
	decay = In.kr(122).lag(0.05);
	freq = In.kr(123).lag(0.05);
	lf_rate = In.kr(124).lag(0.05);
	lf_depth = In.kr(125).lag(0.05);

	lfo = LFNoise2.ar(lf_rate,lf_depth);
	hatnoise = {LPF.ar(WhiteNoise.ar(1), freq + (lfo*2000))};

    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, decay+(lfo*0.125), doneAction: 2)};

    hatoutput = (hatosc * hatenv) * 0.75 * vel;
    Out.ar(out, hatoutput);
}).add;

/******************************************
 * HIHATS B
 */
SynthDef("nun_hat_b", {
	arg out = 42, vel = 1, baseFreq = 300, time = 250, amp=0.2, lf_rate, lf_depth;
	var freqs, signal, pulseEnv, lfo;

	// busses
	time = In.kr(132).lag(0.05);
	baseFreq = In.kr(133).lag(0.05);
	lf_rate = In.kr(134).lag(0.05);
	lf_depth = In.kr(135).lag(0.05);

	lfo = LFNoise2.ar(lf_rate,lf_depth);
	freqs =	[baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523]*(1+(lfo*0.05));
	pulseEnv = EnvGen.ar(Env.new([1.0, 0.6], [time], [-0.5]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
		signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width:0.55)) * (0.9+lfo));
	signal = RLPF.ar(signal, 7000 + (1000*lfo), 0.6);
 	signal = RHPF.ar(signal, 6800 + (1000*lfo), 1.5);
	signal = RHPF.ar(signal, 6800 + (1000*lfo), 1.5);
	signal = RHPF.ar(signal, 1200, 1.5);
	signal = signal + FreeVerb.ar(signal);
		signal = signal * EnvGen.ar(Env.new([0, 1, 0.4, 0, 0], [2, time, 50, 500], [0, -0.5, 0, -50]), timeScale:(1/1000), doneAction:2);
	signal = signal + DelayN.ar(signal, 0.005, 0.005);
	Out.ar(out, signal*4*amp*vel);

}).add;

/******************************************
 * CYMB A
 */
SynthDef("nun_cymb_a", {
	arg out = 43, vel = 1, freq = 1200, sustain = 0.8, amp = 0.08;
	var root_cymbal, root_cymbal_square, root_cymbal_pmosc;
	var initial_bpf_contour, initial_bpf, initial_env;
	var body_hpf, body_env;
	var cymbal_mix;
	// busses
	sustain = In.kr(142).lag(0.05);
	freq = In.kr(143).lag(0.05);

	root_cymbal_square = Pulse.ar(freq, 0.9, mul: 1);
	root_cymbal_pmosc = PMOsc.ar(root_cymbal_square,
					[freq*1.34, freq*2.405, freq*4.09, freq*6.309],
					[freq/1.3, 26/0.5, 11/3.4, 0.72772],
					mul: 2,
					add: 0);
	root_cymbal = root_cymbal_pmosc+WhiteNoise.ar(1);
	initial_bpf_contour = Line.kr(12000, 7000, 0.1);
	initial_env = EnvGen.ar(Env.perc(0.005, 0.1), 1.0);
	initial_bpf = BPF.ar(root_cymbal, initial_bpf_contour, mul:initial_env);
	body_env = EnvGen.ar(Env.perc(0.005, sustain, 1, -2), 1.0, doneAction: 2);
	body_hpf =  HPF.ar(in: root_cymbal, freq: Line.kr(9000, 12000, sustain),mul: body_env, add: 0);
	cymbal_mix = (initial_bpf + body_hpf) * amp * vel;
	Out.ar(out, cymbal_mix ! 1);
}).add;

/******************************************
 * CYMB B
 */
SynthDef("nun_cymb_b",{
	arg out = 44, vel = 1, decay = 2, amp = 0.025;
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, amps, res, thwack;
	decay = In.kr(152).lag(0.05);
	locutoffenv = EnvGen.ar(Env.perc(0.5, 1)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 0.5)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 1, 0.25));

	thwack = EnvGen.ar(Env.perc(0.001,0.001,1));

	freqs  = {exprand(700, 12000)}.dup(80);
	amps   = Array.fill(80, {rrand(0.1,0.9)});

	res = Klank.ar(`[freqs,amps],lodriver + hidriver + thwack);
	res = res * EnvGen.ar(Env.perc(0.05,decay), doneAction:2);
	Out.ar(out, ((res * 1)+ thwack) * amp * vel);
}).add;

/******************************************
 * SUMMATORS and FX SYNTH DEFS
 */
/**
 * Summators/Compander
 */
SynthDef("nun_triple_sum", {
	arg in0 = 0, in1 = 1, in2 = 2,
		pan0 = 0, pan1 = 0, pan2 = 0,
		sbus0 = 3, sbus1 = 4, sbus2 = 5, sbus3 = 6,
		lvlbus0 = 0, lvlbus1 = 0, lvlbus2 = 0, lvlbus3 = 0,
		vol = 1, comp = 0, out = 0;

	var mixed, mix0, mix1, mix2, compr;
	// mix 0
	mix0 = Pan2.ar(In.ar(in0,1), pan0);
    mix1 = Pan2.ar(In.ar(in1,1), pan1);
	mix2 = Pan2.ar(In.ar(in2,1), pan2);

	mixed = Mix.new([mix0,mix1,mix2]);
	//compr = CompanderD.ar(mixed, -25.dbamp, 1, 0.35, 0.08, 0.1);
	//mixed = SelectX.ar(comp*2,[mixed,compr]);

	Out.ar(out, mixed*vol);
	// out to FX busses
	Out.ar(sbus0, mixed*lvlbus0);
	Out.ar(sbus1, mixed*lvlbus1);
	Out.ar(sbus2, mixed*lvlbus2);
	Out.ar(sbus3, mixed*lvlbus3);
}).add;

SynthDef("nun_double_sum", {
	arg in0 = 0, in1 = 1,
		pan0 = 0, pan1 = 0,
		sbus0 = 3, sbus1 = 4, sbus2 = 5, sbus3 = 6,
		lvlbus0 = 0, lvlbus1 = 0, lvlbus2 = 0, lvlbus3 = 0,
		vol = 1, comp = 0, out = 0;

	var mixed, mix0, mix1, compr;
	mix0 = Pan2.ar(In.ar(in0,1), pan0);
    mix1 = Pan2.ar(In.ar(in1,1), pan1);
	mixed = Mix.new([mix0,mix1]);

	//compr = CompanderD.ar(mixed, -25.dbamp, 1, 0.35, 0.01, 0.5);
	//mixed = SelectX.ar(comp*2,[mixed,compr]);

	Out.ar(out, mixed*vol);
	Out.ar(sbus0, mixed*lvlbus0);
	Out.ar(sbus1, mixed*lvlbus1);
	Out.ar(sbus2, mixed*lvlbus2);
	Out.ar(sbus3, mixed*lvlbus3);
}).add;

// main console
SynthDef("nun_main_console", {
		arg sin0 = 0, sin1 = 2, sin2 = 4, sin3 = 6, sin4 = 8,
		    sbus0 = 0, sbus1 = 2, sbus2 = 4, sbus3 = 6,
		    out = 0;
		var drymix, busmix, mainmix;
		drymix = Mix.new([In.ar(sin0,2),In.ar(sin1,2),In.ar(sin2,2),In.ar(sin3,2),In.ar(sin4,2)]);
		busmix = Mix.new([In.ar(sbus0,2),In.ar(sbus1,2),In.ar(sbus2,2),In.ar(sbus3,2)]);
		mainmix = Mix.new([drymix,busmix]);
		Out.ar(out, mainmix);
}).add;


/**
 * waveshaper
 */
~sineSig = Signal.chebyFill(1000, [0, 0.2, 0.8, 0.1, 0.5]);//Signal.sineFill(1000, [1, 0.2, 0.7]);//Signal.sineFill(1000, 1.0/[1, 2, 3, 4, 5, 6]);
~waveShapeBuffer = Buffer.alloc(s,1000,1,{},0);
~waveShapeBuffer.loadCollection(~sineSig, 0);

SynthDef("nun_nasty", {
		arg in, out, buff;
		var soundIn, playHead, output, thisIndex;
		soundIn = In.ar(in,2)*2;
		//thisIndex = LinLin.ar(soundIn, -1.0, 1.0, 0.0, BufFrames.kr(buff));
		thisIndex = LinLin.ar(soundIn, -1.0, 1.0, 0.0, BufFrames.kr(buff) * LFNoise2.kr(0.6).range(0.0,1.0));
		playHead = BufRd.ar(1, buff, thisIndex, 0, 4);
		output = LeakDC.ar(playHead)*Amplitude.kr(soundIn);
		output = DFM1.ar(output,14000,0.2,10,0.0008)*0.1;
		Out.ar(out, output!2);
}).add;

/**
 * Reverb
 */
SynthDef("nun_reverb_a", {
	arg in = 0, out = 0;
	var s, z, y, vol;
	s = In.ar(in,2);
	z = DelayN.ar(s, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 4) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	s = s+y;
	Out.ar(out,s);
}).add;

/******************************************
 * SERVER SYNC
 */
s.sync;

/******************************************
 * ROUTE
 */
~drum_source = Group.head(s);
~drum_premix = Group.tail(s);
~drum_fx = Group.tail(s);
~drum_mixdown = Group.tail(s);

/*****
 * Premix
 * -- Drum Mono Busses
 * 32 33 34 35 36 37 38 39 40 41 42 43 44
 * -- Drum Premix Stereo Busses
 * 45:46 47:48 49:50 51:52 53:54
 * -- FX Stereo Busses
 *  fx0: 55:56
 *  fx1: 57:58
 *  fx2: 59:60
 *  fx3: 61:62
 */
~drum_kick_premixer = Synth.head(~drum_premix, "nun_triple_sum");
~drum_kick_premixer.set(
		\in0, 32, \in1, 33, \in2, 34,
		\pan0, 0,\pan1, 0, \pan2, 0,
		\sbus0 , 55, \sbus1 , 57, \sbus2 , 59, \sbus3 , 61,
		\out, 45);
~drum_drums_premixer = Synth.head(~drum_premix, "nun_triple_sum");
~drum_drums_premixer.set(
		\in0, 35, \in1, 36, \in2, 37,
		\pan0, -0.2,\pan1, 0.2, \pan2, 0,
		\sbus0 , 55, \sbus1 , 57, \sbus2 , 59, \sbus3 , 61,
		\out, 47);
~drum_snare_premixer = Synth.head(~drum_premix, "nun_triple_sum");
~drum_snare_premixer.set(
		\in0, 38, \in1, 39, \in2, 40,
		\pan0, -0.1,\pan1, 0.1, \pan2, 0.3,
		\sbus0 , 55, \sbus1 , 57, \sbus2 , 59, \sbus3 , 61,
		\out, 49);
~drum_hh_premixer = Synth.head(~drum_premix, "nun_double_sum");
~drum_hh_premixer.set(
		\in0, 41, \in1, 42,
		\pan0, -0.15,\pan1, 0.15,
		\sbus0 , 55, \sbus1 , 57, \sbus2 , 59, \sbus3 , 61,
		\out, 51);
~drum_cym_premixer = Synth.head(~drum_premix, "nun_double_sum");
~drum_cym_premixer.set(
		\in0, 43, \in1, 44,
		\pan0, -0.3,\pan1, 0.3,
		\sbus0 , 55, \sbus1 , 57, \sbus2 , 59, \sbus3 , 61,
		\out, 53);
/*
 * EFFECTS STACK
 */
~fx_nasty = Synth.head(~drum_fx, "nun_nasty");
~fx_nasty.set(\in, 55, \out, 55, \buff, ~waveShapeBuffer);
~fx_reverb = Synth.head(~drum_fx, "nun_reverb_a");
~fx_reverb.set(\in, 57, \out, 57);
/**
 * MAIN MIX
 */
~drum_main_mixer = Synth.head(~drum_mixdown, "nun_main_console");
~drum_main_mixer.set(
		\sin0 , 45, \sin1 , 47, \sin2 , 49, \sin3 , 51, \sin4 , 53,
		\sbus0 , 55, \sbus1 , 57, \sbus2 , 59, \sbus3 , 61,
		\out, ~mainOut
	);

}.fork }; // asynchronous



/******************************************
 * GUI
 */

~load_drum_gui = {
// DRUM CONTROLLER VIEW
var
main_window,
// hard a
hakick_panel,
hakick_lbl,
hakick_controls,
// hard b
hbkick_panel,
hbkick_lbl,
hbkick_controls,
// soft kick
skick_panel,
skick_lbl,
skick_controls,
// drum A
adrum_panel,
adrum_lbl,
adrum_controls,
//drum B
bdrum_panel,
bdrum_lbl,
bdrum_controls,
//drum C
cdrum_panel,
cdrum_lbl,
cdrum_controls,
// snare a
asnare_panel,
asnare_lbl,
asnare_controls,
// snare b
bsnare_panel,
bsnare_lbl,
bsnare_controls,
// clap
clap_panel,
clap_lbl,
clap_controls,
// hats a
ahat_panel,
ahat_lbl,
ahat_controls,
// hats b
bhat_panel,
bhat_lbl,
bhat_controls,
// a cymb
acymb_panel,
acymb_lbl,
acymb_controls,
// b cymb
bcymb_controls,
bcymb_lbl,
bcymb_panel
;
// MIXER WINDOW VIEW
var
mixer_window,

premix0_panel,
premix0_lbl,
premix0_controls,

premix1_panel,
premix1_lbl,
premix1_controls,

premix2_panel,
premix2_lbl,
premix2_controls,

premix3_panel,
premix3_lbl,
premix3_controls,

premix4_panel,
premix4_lbl,
premix4_controls;


mixer_window = Window.new("Drum Synth Mixer", Rect(50,100,400,515));
main_window = Window.new("Drum Synth Controller", Rect(300,100,957,515));
mixer_window.front;
main_window.front;
mixer_window.alwaysOnTop = true;

/******************************************************************************************************************************
 * DRUM MIXER
 ******************************************************************************************************************************/

premix0_panel = HLayoutView(mixer_window, Rect(10,30,305,75));
premix0_panel.background_(Color.fromHexString("#999999"));
premix0_lbl = StaticText(mixer_window, Rect(10, 10, 150, 20));
premix0_lbl.string = "KICK MIX";

premix0_controls.add(EZKnob(premix0_panel, 40@74, "vol", [0, 1].asSpec.default = 1, { |widget|
	~drum_kick_premixer.set(\vol,widget.value);
},layout:\vert2, initAction:true ));
/*
premix0_controls.add(EZKnob(premix0_panel, 40@74, "comp", [0, 1].asSpec.default = 0, { |widget|
	~drum_kick_premixer.set(\comp,widget.value);
},layout:\vert2, initAction:true ));
*/
premix0_controls.add(EZKnob(premix0_panel, 40@74, "fx0", [0, 1].asSpec.default = 0, { |widget|
	~drum_kick_premixer.set(\lvlbus0,widget.value);
},layout:\vert2, initAction:true ));
premix0_controls.add(EZKnob(premix0_panel, 40@74, "fx1", [0, 1].asSpec.default = 0, { |widget|
	~drum_kick_premixer.set(\lvlbus1,widget.value);
},layout:\vert2, initAction:true ));
premix0_controls.add(EZKnob(premix0_panel, 40@74, "fx2", [0, 1].asSpec.default = 0, { |widget|
	~drum_kick_premixer.set(\lvlbus2,widget.value);
},layout:\vert2, initAction:true ));
premix0_controls.add(EZKnob(premix0_panel, 40@74, "fx3", [0, 1].asSpec.default = 0, { |widget|
	~drum_kick_premixer.set(\lvlbus3,widget.value);
},layout:\vert2, initAction:true ));

premix1_panel = HLayoutView(mixer_window, Rect(10,130,305,75));
premix1_panel.background_(Color.fromHexString("#999999"));
premix1_lbl = StaticText(mixer_window, Rect(10, 110, 150, 20));
premix1_lbl.string = "DRUMS MIX";

premix1_controls.add(EZKnob(premix1_panel, 40@74, "vol", [0, 1].asSpec.default = 1, { |widget|
	~drum_drums_premixer.set(\vol,widget.value);
},layout:\vert2, initAction:true ));
/*
premix1_controls.add(EZKnob(premix1_panel, 40@74, "comp", [0, 1].asSpec.default = 0, { |widget|
	~drum_drums_premixer.set(\comp,widget.value);
},layout:\vert2, initAction:true ));
*/
premix1_controls.add(EZKnob(premix1_panel, 40@74, "fx0", [0, 1].asSpec.default = 0, { |widget|
	~drum_drums_premixer.set(\lvlbus0,widget.value);
},layout:\vert2, initAction:true ));
premix1_controls.add(EZKnob(premix1_panel, 40@74, "fx1", [0, 1].asSpec.default = 0, { |widget|
	~drum_drums_premixer.set(\lvlbus1,widget.value);
},layout:\vert2, initAction:true ));
premix1_controls.add(EZKnob(premix1_panel, 40@74, "fx2", [0, 1].asSpec.default = 0, { |widget|
	~drum_drums_premixer.set(\lvlbus2,widget.value);
},layout:\vert2, initAction:true ));
premix1_controls.add(EZKnob(premix1_panel, 40@74, "fx3", [0, 1].asSpec.default = 0, { |widget|
	~drum_drums_premixer.set(\lvlbus3,widget.value);
},layout:\vert2, initAction:true ));

premix2_panel = HLayoutView(mixer_window, Rect(10,230,305,75));
premix2_panel.background_(Color.fromHexString("#999999"));
premix2_lbl = StaticText(mixer_window, Rect(10, 210, 150, 20));
premix2_lbl.string = "SNARE MIX";

premix2_controls.add(EZKnob(premix2_panel, 40@74, "vol", [0, 1].asSpec.default = 1, { |widget|
	~drum_snare_premixer.set(\vol,widget.value);
},layout:\vert2, initAction:true ));
/*
premix2_controls.add(EZKnob(premix2_panel, 40@74, "comp", [0, 1].asSpec.default = 0, { |widget|
	~drum_snare_premixer.set(\comp,widget.value);
},layout:\vert2, initAction:true ));
*/
premix2_controls.add(EZKnob(premix2_panel, 40@74, "fx0", [0, 1].asSpec.default = 0, { |widget|
	~drum_snare_premixer.set(\lvlbus0,widget.value);
},layout:\vert2, initAction:true ));
premix2_controls.add(EZKnob(premix2_panel, 40@74, "fx1", [0, 1].asSpec.default = 0, { |widget|
	~drum_snare_premixer.set(\lvlbus1,widget.value);
},layout:\vert2, initAction:true ));
premix2_controls.add(EZKnob(premix2_panel, 40@74, "fx2", [0, 1].asSpec.default = 0, { |widget|
	~drum_snare_premixer.set(\lvlbus2,widget.value);
},layout:\vert2, initAction:true ));
premix2_controls.add(EZKnob(premix2_panel, 40@74, "fx3", [0, 1].asSpec.default = 0, { |widget|
	~drum_snare_premixer.set(\lvlbus3,widget.value);
},layout:\vert2, initAction:true ));

premix3_panel = HLayoutView(mixer_window, Rect(10,330,305,75));
premix3_panel.background_(Color.fromHexString("#999999"));
premix3_lbl = StaticText(mixer_window, Rect(10, 310, 150, 20));
premix3_lbl.string = "HH MIX";

premix3_controls.add(EZKnob(premix3_panel, 40@74, "vol", [0, 1].asSpec.default = 1, { |widget|
	~drum_hh_premixer.set(\vol,widget.value);
},layout:\vert2, initAction:true ));
/*
premix3_controls.add(EZKnob(premix3_panel, 40@74, "comp", [0, 1].asSpec.default = 0, { |widget|
	~drum_hh_premixer.set(\comp,widget.value);
},layout:\vert2, initAction:true ));
*/
premix3_controls.add(EZKnob(premix3_panel, 40@74, "fx0", [0, 1].asSpec.default = 0, { |widget|
	~drum_hh_premixer.set(\lvlbus0,widget.value);
},layout:\vert2, initAction:true ));
premix3_controls.add(EZKnob(premix3_panel, 40@74, "fx1", [0, 1].asSpec.default = 0, { |widget|
	~drum_hh_premixer.set(\lvlbus1,widget.value);
},layout:\vert2, initAction:true ));
premix3_controls.add(EZKnob(premix3_panel, 40@74, "fx2", [0, 1].asSpec.default = 0, { |widget|
	~drum_hh_premixer.set(\lvlbus2,widget.value);
},layout:\vert2, initAction:true ));
premix3_controls.add(EZKnob(premix3_panel, 40@74, "fx3", [0, 1].asSpec.default = 0, { |widget|
	~drum_hh_premixer.set(\lvlbus3,widget.value);
},layout:\vert2, initAction:true ));

premix4_panel = HLayoutView(mixer_window, Rect(10,430,305,75));
premix4_panel.background_(Color.fromHexString("#999999"));
premix4_lbl = StaticText(mixer_window, Rect(10, 410, 150, 20));
premix4_lbl.string = "CYMB MIX";

premix4_controls.add(EZKnob(premix4_panel, 40@74, "vol", [0, 1].asSpec.default = 1, { |widget|
	~drum_cym_premixer.set(\vol,widget.value);
},layout:\vert2, initAction:true ));
/*
premix4_controls.add(EZKnob(premix4_panel, 40@74, "comp", [0, 1].asSpec.default = 0, { |widget|
	~drum_cym_premixer.set(\comp,widget.value);
},layout:\vert2, initAction:true ));
*/
premix4_controls.add(EZKnob(premix4_panel, 40@74, "fx0", [0, 1].asSpec.default = 0, { |widget|
	~drum_cym_premixer.set(\lvlbus0,widget.value);
},layout:\vert2, initAction:true ));
premix4_controls.add(EZKnob(premix4_panel, 40@74, "fx1", [0, 1].asSpec.default = 0, { |widget|
	~drum_cym_premixer.set(\lvlbus1,widget.value);
},layout:\vert2, initAction:true ));
premix4_controls.add(EZKnob(premix4_panel, 40@74, "fx2", [0, 1].asSpec.default = 0, { |widget|
	~drum_cym_premixer.set(\lvlbus2,widget.value);
},layout:\vert2, initAction:true ));
premix4_controls.add(EZKnob(premix4_panel, 40@74, "fx3", [0, 1].asSpec.default = 0, { |widget|
	~drum_cym_premixer.set(\lvlbus3,widget.value);
},layout:\vert2, initAction:true ));

/******************************************************************************************************************************
 * DRUM CONTROLLER
 ******************************************************************************************************************************/

/******************************************
 * H KICK A
 * 32 33 34 35 36 37 38
 */
hakick_panel = HLayoutView(main_window, Rect(10,30,305,75));
hakick_panel.background_(Color.fromHexString("#FF9955"));

hakick_lbl = StaticText(main_window, Rect(10, 10, 150, 20));
hakick_lbl.string = "HARD KICK A";

hakick_controls = [];
hakick_controls.add(Button(hakick_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_kick_a"); }));
View(hakick_panel,Rect(0,0,5,10));// spacer
//dec1
hakick_controls.add(EZKnob(hakick_panel, 40@74, "dec1", [0.05, 1].asSpec.default = 0.3, { |widget|
	var bus = Bus.new('control',32,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
//freq
hakick_controls.add(EZKnob(hakick_panel, 40@74, "feq", [20, 120].asSpec.default = 30, { |widget|
	var bus = Bus.new('control',33,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// sweep
hakick_controls.add(EZKnob(hakick_panel, 40@74, "sweep", [0.05, 0.2].asSpec.default = 0.08, { |widget|
	var bus = Bus.new('control',34,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// ratio
hakick_controls.add(EZKnob(hakick_panel, 40@74, "ratio", [2, 15].asSpec.default = 7, { |widget|
	var bus = Bus.new('control',35,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// dist
hakick_controls.add(EZKnob(hakick_panel, 40@74, "dist", [0, 1].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',36,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// filt
hakick_controls.add(EZKnob(hakick_panel, 40@74, "filt", \freq.asSpec.default = 20000, { |widget|
	var bus = Bus.new('control',37,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// mover
hakick_controls.add(EZKnob(hakick_panel, 40@74, "mover", [0, 1].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',38,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * H KICK B
 * 42 43 44 45 46 47
 */
hbkick_panel = HLayoutView(main_window, Rect(10,130,305,75));
hbkick_panel.background_(Color.fromHexString("#CC9955"));

hbkick_lbl = StaticText(main_window, Rect(10, 110, 150, 20));
hbkick_lbl.string = "HARD KICK B";

hbkick_controls = [];
hbkick_controls.add(Button(hbkick_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_kick_b"); }));
View(hbkick_panel,Rect(0,0,5,10));// spacer

//dec1
hbkick_controls.add(EZKnob(hbkick_panel, 40@74, "dec1", [0.05, 1].asSpec.default = 0.3, { |widget|
	var bus = Bus.new('control',42,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// shape1
hakick_controls.add(EZKnob(hbkick_panel, 40@74, "shp1", [30, 100].asSpec.default = 59, { |widget|
	var bus = Bus.new('control',43,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// shape2
hakick_controls.add(EZKnob(hbkick_panel, 40@74, "shp2", [20, 50].asSpec.default = 29, { |widget|
	var bus = Bus.new('control',44,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// click
hakick_controls.add(EZKnob(hbkick_panel, 40@74, "clik", [70, 200].asSpec.default = 110, { |widget|
	var bus = Bus.new('control',45,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// noise
hakick_controls.add(EZKnob(hbkick_panel, 40@74, "noiz", [0, 1].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',46,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// filt
hakick_controls.add(EZKnob(hbkick_panel, 40@74, "filt", \freq.asSpec.default = 20000, { |widget|
	var bus = Bus.new('control',47,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * SOFT KICK
 * 52 53 54 55 56
 */
skick_panel = HLayoutView(main_window, Rect(10,230,305,75));
skick_panel.background_(Color.fromHexString("#BBAA55"));

skick_lbl = StaticText(main_window, Rect(10, 210, 150, 20));
skick_lbl.string = "SOFT KICK";

skick_controls = [];
skick_controls.add(Button(skick_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_kick_c"); }));
View(skick_panel,Rect(0,0,5,10));// spacer
//dec1
skick_controls.add(EZKnob(skick_panel, 40@74, "dec1", [0.05, 1].asSpec.default = 0.3, { |widget|
	var bus = Bus.new('control',52,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
//freq
skick_controls.add(EZKnob(skick_panel, 40@74, "freq", [20, 120].asSpec.default = 40, { |widget|
	var bus = Bus.new('control',53,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// mod_freq
skick_controls.add(EZKnob(skick_panel, 40@74, "mfrq", [0, 300].asSpec.default = 1, { |widget|
	var bus = Bus.new('control',54,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// filter_freq
skick_controls.add(EZKnob(skick_panel, 40@74, "filt", \freq.asSpec.default = 12000, { |widget|
	var bus = Bus.new('control',55,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
skick_controls.add(EZKnob(skick_panel, 40@74, "dist", [0,20].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',56,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * DRUM A
 * 62 63 64 65 66
 */
adrum_panel = HLayoutView(main_window, Rect(10, 330,305,75));
adrum_panel.background_(Color.fromHexString("#99AA55"));

adrum_lbl = StaticText(main_window, Rect(10, 310, 150, 20));
adrum_lbl.string = "DRUM A";

adrum_controls.add(Button(adrum_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_drum_a"); }));
View(skick_panel,Rect(0,0,5,10));// spacer
// dec1
adrum_controls.add(EZKnob(adrum_panel, 40@74, "dec1", [0.05, 2].asSpec.default = 0.35, { |widget|
	var bus = Bus.new('control',62,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq
adrum_controls.add(EZKnob(adrum_panel, 40@74, "freq", [40, 400].asSpec.default = 80, { |widget|
	var bus = Bus.new('control',63,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// wave
adrum_controls.add(EZKnob(adrum_panel, 40@74, "wave", [0, 2].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',64,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// mod
adrum_controls.add(EZKnob(adrum_panel, 40@74, "mtype", [0, 4].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',65,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// mod depth
adrum_controls.add(EZKnob(adrum_panel, 40@74, "mdep", [0, 1].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',66,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// mod speed
adrum_controls.add(EZKnob(adrum_panel, 40@74, "mspd", [0, 400].asSpec.default = 4, { |widget|
	var bus = Bus.new('control',67,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * DRUM B
 * 72 73 74 75 76
 */
bdrum_panel = HLayoutView(main_window, Rect(10, 430,305,75));
bdrum_panel.background_(Color.fromHexString("#55AA55"));

bdrum_lbl = StaticText(main_window, Rect(10, 410, 150, 20));
bdrum_lbl.string = "DRUM B";

bdrum_controls = [];
bdrum_controls.add(Button(bdrum_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_drum_b"); }));
View(bdrum_panel,Rect(0,0,5,10));// spacer

// dec1
bdrum_controls.add(EZKnob(bdrum_panel, 40@74, "dec1", [0.05, 2].asSpec.default = 0.4, { |widget|
	var bus = Bus.new('control',72,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq
bdrum_controls.add(EZKnob(bdrum_panel, 40@74, "freq", [40, 400].asSpec.default = 90, { |widget|
	var bus = Bus.new('control',73,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// drum_mode_level
bdrum_controls.add(EZKnob(bdrum_panel, 40@74, "mdlvl", [0, 1].asSpec.default = 0.25, { |widget|
	var bus = Bus.new('control',74,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// timbre
bdrum_controls.add(EZKnob(bdrum_panel, 40@74, "timbr", [0, 50].asSpec.default = 1.0, { |widget|
	var bus = Bus.new('control',75,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * DRUM C
 * 102 103 104 105 106
 */
cdrum_panel = HLayoutView(main_window, Rect(325, 30,305,75));
cdrum_panel.background_(Color.fromHexString("#559999"));

cdrum_lbl = StaticText(main_window, Rect(325, 10, 150, 20));
cdrum_lbl.string = "DRUM C";

cdrum_controls = [];
cdrum_controls.add(Button(cdrum_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_drum_c"); }));
View(bdrum_panel,Rect(0,0,5,10));// spacer
// tension
cdrum_controls.add(EZKnob(cdrum_panel, 40@74, "tens", [0.0005, 0.02].asSpec.default = 0.00411, { |widget|
	var bus = Bus.new('control',102,1,s);
	bus.set(widget.value);
	widget.value.postln;
},layout:\vert2, initAction:true ));
// loss
cdrum_controls.add(EZKnob(cdrum_panel, 40@74, "loss", [0.9990, 2].asSpec.default = 0.9998, { |widget|
	var bus = Bus.new('control',103,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// time
cdrum_controls.add(EZKnob(cdrum_panel, 40@74, "time", [0.1, 1].asSpec.default = 0.2, { |widget|
	var bus = Bus.new('control',104,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// attack
cdrum_controls.add(EZKnob(cdrum_panel, 40@74, "atk", [0.001, 0.5].asSpec.default = 0.01, { |widget|
	var bus = Bus.new('control',105,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// hpf
cdrum_controls.add(EZKnob(cdrum_panel, 40@74, "hpf", \freq.asSpec.default = 30, { |widget|
	var bus = Bus.new('control',106,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * SNARE A
 * 82 83 84 85 86
 */
asnare_panel = HLayoutView(main_window, Rect(325, 130,305,75));
asnare_panel.background_(Color.fromHexString("#5599AA"));

asnare_lbl = StaticText(main_window, Rect(325, 110, 150, 20));
asnare_lbl.string = "SNARE A";

asnare_controls = [];
asnare_controls.add(Button(asnare_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_snare_a"); }));
View(asnare_panel,Rect(0,0,5,10));// spacer

// dec1
asnare_controls.add(EZKnob(asnare_panel, 40@74, "dec1", [0.05, 2].asSpec.default = 0.2, { |widget|
	var bus = Bus.new('control',82,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq1
asnare_controls.add(EZKnob(asnare_panel, 40@74, "freq1", [40,800].asSpec.default = 138, { |widget|
	var bus = Bus.new('control',83,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq2
asnare_controls.add(EZKnob(asnare_panel, 40@74, "freq1", [40,3000].asSpec.default = 261, { |widget|
	var bus = Bus.new('control',84,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// filt
asnare_controls.add(EZKnob(asnare_panel, 40@74, "filt", \freq.asSpec.default = 7000, { |widget|
	var bus = Bus.new('control',85,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// dist
asnare_controls.add(EZKnob(asnare_panel, 40@74, "dist", [0, 1].asSpec.default = 0.15, { |widget|
	var bus = Bus.new('control',86,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * SNARE B
 * 92 93 94 95 96
 */
bsnare_panel = HLayoutView(main_window, Rect(325, 230,305,75));
bsnare_panel.background_(Color.fromHexString("#5599CC"));

bsnare_lbl = StaticText(main_window, Rect(325, 210, 150, 20));
bsnare_lbl.string = "SNARE B";

bsnare_controls = [];
bsnare_controls.add(Button(bsnare_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_snare_b"); }));
View(bsnare_panel,Rect(0,0,5,10));// spacer

// dec1
bsnare_controls.add(EZKnob(bsnare_panel, 40@74, "dec1", [0.05, 2].asSpec.default = 0.1, { |widget|
	var bus = Bus.new('control',92,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq1
bsnare_controls.add(EZKnob(bsnare_panel, 40@74, "freq", [100,800].asSpec.default = 405, { |widget|
	var bus = Bus.new('control',93,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// tightness
bsnare_controls.add(EZKnob(bsnare_panel, 40@74, "tight", [400,8000].asSpec.default = 1000, { |widget|
	var bus = Bus.new('control',94,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// drum_mode_level
bsnare_controls.add(EZKnob(bsnare_panel, 40@74, "mode", [0,1].asSpec.default = 0.25, { |widget|
	var bus = Bus.new('control',95,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// snare
bsnare_controls.add(EZKnob(bsnare_panel, 40@74, "snare", [1,100].asSpec.default = 40, { |widget|
	var bus = Bus.new('control',96,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * CLAP
 * 112 113 114 115 116
 */
clap_panel = HLayoutView(main_window, Rect(325, 330,305,75));
clap_panel.background_(Color.fromHexString("#4499EE"));

clap_lbl = StaticText(main_window, Rect(325, 310, 150, 20));
clap_lbl.string = "HAND CLAP";

clap_controls = [];
clap_controls.add(Button(clap_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_clap"); }));
View(clap_panel,Rect(0,0,5,10));// spacer
// dec1
clap_controls.add(EZKnob(clap_panel, 40@74, "dec1", [0.05, 2].asSpec.default = 0.2, { |widget|
	var bus = Bus.new('control',112,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// filt
clap_controls.add(EZKnob(clap_panel, 40@74, "filt", \freq.asSpec.default = 12000, { |widget|
	var bus = Bus.new('control',113,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * HI HATS A
 * 122 123 124 125 126
 */
ahat_panel = HLayoutView(main_window, Rect(640, 30,305,75));
ahat_panel.background_(Color.fromHexString("#CC99CC"));

ahat_lbl = StaticText(main_window, Rect(640, 10, 150, 20));
ahat_lbl.string = "HH A";

ahat_controls = [];

ahat_controls.add(Button(ahat_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_hat_a"); }));
View(ahat_panel,Rect(0,0,5,10));// spacer
// dec1
ahat_controls.add(EZKnob(ahat_panel, 40@74, "dec1", [0.02, 1].asSpec.default = 0.2, { |widget|
	var bus = Bus.new('control',122,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq
ahat_controls.add(EZKnob(ahat_panel, 40@74, "freq", \freq.asSpec.default = 6000, { |widget|
	var bus = Bus.new('control',123,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// lfrate
ahat_controls.add(EZKnob(ahat_panel, 40@74, "lfrat", [0.1,20].asSpec.default = 1, { |widget|
	var bus = Bus.new('control',124,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// lfdepth
ahat_controls.add(EZKnob(ahat_panel, 40@74, "lfdep", [0,1].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',125,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));


/******************************************
 * HI HATS B
 * 132 133 134 135 136
 */
bhat_panel = HLayoutView(main_window, Rect(640, 130,305,75));
bhat_panel.background_(Color.fromHexString("#FF88CC"));

bhat_lbl = StaticText(main_window, Rect(640, 110, 150, 20));
bhat_lbl.string = "HH B";

bhat_controls = [];

bhat_controls.add(Button(bhat_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_hat_b"); }));
View(bhat_panel,Rect(0,0,5,10));// spacer
// dec1
bhat_controls.add(EZKnob(bhat_panel, 40@74, "dec1", [10, 1000].asSpec.default = 250, { |widget|
	var bus = Bus.new('control',132,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq
bhat_controls.add(EZKnob(bhat_panel, 40@74, "basef", [80,3000].asSpec.default = 300, { |widget|
	var bus = Bus.new('control',133,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// lfrate
bhat_controls.add(EZKnob(bhat_panel, 40@74, "lfrat", [0.1,20].asSpec.default = 1, { |widget|
	var bus = Bus.new('control',134,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// lfdepth
bhat_controls.add(EZKnob(bhat_panel, 40@74, "lfdep", [0,1].asSpec.default = 0, { |widget|
	var bus = Bus.new('control',135,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

/******************************************
 * CYMB A
 * 142 143 144 145 146
 */
acymb_panel = HLayoutView(main_window, Rect(640, 230,305,75));
acymb_panel.background_(Color.fromHexString("#FFAACC"));

acymb_lbl = StaticText(main_window, Rect(640, 210, 150, 20));
acymb_lbl.string = "CYMB A";

acymb_controls = [];

acymb_controls.add(Button(acymb_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_cymb_a"); }));
View(acymb_panel,Rect(0,0,5,10));// spacer
// dec1
acymb_controls.add(EZKnob(acymb_panel, 40@74, "dec1", [0.1, 2].asSpec.default = 0.6, { |widget|
	var bus = Bus.new('control',142,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq
bhat_controls.add(EZKnob(acymb_panel, 40@74, "basef", [80,6000].asSpec.default = 800, { |widget|
	var bus = Bus.new('control',143,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
/******************************************
 * CYMB B
 * 152
 */
bcymb_panel = HLayoutView(main_window, Rect(640, 330,305,75));
bcymb_panel.background_(Color.fromHexString("#FFCC99"));

bcymb_lbl = StaticText(main_window, Rect(640, 310, 150, 20));
bcymb_lbl.string = "CYMB B";

bcymb_controls = [];

bcymb_controls.add(Button(bcymb_panel,Rect(0,0,15,10)).action_({ Synth.head(~drum_source,"nun_cymb_b"); }));
View(bcymb_panel,Rect(0,0,5,10));// spacer
// dec1
bcymb_controls.add(EZKnob(bcymb_panel, 40@74, "dec1", [0.1, 2].asSpec.default = 2, { |widget|
	var bus = Bus.new('control',152,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));

}; // function end
/// end
)



/******************************************
 * THRASHED CODE
 */
/******************************************
 * THRASHED CODE
 */
/******************************************
 * THRASHED CODE
 */
/******************************************
 * THRASHED CODE
 */
/*
|in = 0, out = 0, drv = 40, amp = 0.15, jitf = 0.8, jit = 0.5,env = 0.1,
	 lag = 1, lpp = 120, res = 0.2, gate = 1, att = 0.001, rel = 0.1|
	var sig, x3, jitter, input, envf;
	lag = lag*LFNoise2.kr(1).range(0.2,3);
	input = In.ar(in, 2);
	drv = Lag.kr(drv, lag).dbamp;
	sig = drv * Clipper8.ar(input, -1.875,1.875);
	envf = AmplitudeMod.ar(input,att, rel);
	jitter =  (envf * jit*LFNoise2.kr(1).range(0.7,1.3))+1;
	x3 = sig.pow(3);
	sig = ((x3 *(-0.18963)) + sig) + (x3*sig.pow(2) * 0.0161817*jitter*LFNoise2.kr(1).range(0.7,1.3));
	sig = SoftClipper8.ar(sig);
	sig = XFade2.ar(sig, sig*envf, (env * 2)-1);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig,12000);
	sig = Mix.ar([input,sig]);
	Out.ar(out, sig * Lag.kr(amp, 1));
*/

