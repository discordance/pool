/******************************************
 * Nunja Drum Machine - Supercollider
 */

(
{
/******************************************
 * KICK and Bass Drums
 */
/******************************************
 * HARD KICK A
 */
SynthDef(\nun_kick_a,{
	arg basefreq = 50,
	ratio = 7,
	sweeptime = 0.05,
	preamp = 0.8,
	amp = 0.75,
	dist = 0,
	decay1 = 0.3,
    freq = 20000,
	mover = 0,
    out;

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
	sig = sig * env * amp;
    // filter quirked
	freq = LFNoise2.kr(80).exprange(freq-100,freq+100).clip(20,20000);
	sig = RLPF.ar(sig, freq, 1);
	//sig = Compander.ar(sig, sig, 0.5, 1, 0.1, 0.01, 0.01);
    Out.ar(out, sig ! 2);
}).add;

/******************************************
 * HARD KICK B
 */
SynthDef(\nun_kick_b,{
	arg out=0, amp=0.5, pan=0,
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
	sig = sig * amp;
	//sig = Compander.ar(sig, sig, 0.5, 1, 0.5, 0.1, 0.1);
	Out.ar(out, sig ! 2);

}).add;

/******************************************
 * SOFT KICK
 */
SynthDef(\nun_kick_c,{
	arg out = 0,
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
	mix = DFM1.ar(mix, filter_freq, 0.1, 1+distortion, 0)*amp;//RLPF.ar(mix, filter_freq);
	Out.ar(out, mix ! 2);

}).add;

/******************************************
 * DRUM A
 */
SynthDef("nun_drum_a", {
	|outBus = 0, midiFreq = 60, gate = 1.0, amp = 0.5, freqMult = 1,
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
	output = tanh(output) * ampEnvGen * amp;

	Out.ar(outBus, output ! 2);
	}
).add;

/******************************************
 * DRUM B
 */
SynthDef("nun_drum_b", {
	arg out = 0, sustain = 0.6, drum_mode_level = 0.25,
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
	tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp;
	Out.ar(out, [tom_mix, tom_mix])
}).add;

/******************************************
 * SNARE A
 */
SynthDef("nun_snare_a", {

	arg out=0, amp=0.7, decay, freq1, freq2, filt, dist;
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
	sig = SelectX.ar(dist * 2, [sig, dist_sig] ) * amp;
	sig = DFM1.ar(sig,filt);
	Out.ar(out, sig.dup);
}).add;

/******************************************
 * SNARE B
 */
SynthDef("nun_snare_b", {
	arg out = 0, sustain = 0.1, drum_mode_level = 0.25,
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
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
	snare_drum_mix = CompanderD.ar(snare_drum_mix, thresh: -30.dbamp, slopeBelow: 1, slopeAbove: 0.15, clampTime: 0.003, relaxTime: 0.08);
	snare_drum_mix = (snare_drum_mix * (16.dbamp));
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
}).add;

/******************************************
 * DRUM C
 */
SynthDef("nun_drum_c", {
	arg out=0,
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
	brane = (brane * (16.dbamp));
    Out.ar(out, brane ! 2);
}).add;

/******************************************
 * CLAP
 */
SynthDef("nun_clap", {
	arg outBus=0, amp = 0.5, sustain = 0.2, filt;
	var env1, env2, out, noise1, noise2, lf1;
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

	out = noise1 + noise2;
	out = out * 10;
	out = out.softclip * amp;
	Out.ar(outBus, MoogFF.ar(out.dup,filt));

}).add;

/******************************************
 * SERVER SYNC
 */
s.sync;

/******************************************
 * ROUTE
 */
~drum_source = Group.head(s);

}.fork // asynchronous
)


/******************************************
 * GUI
 */
(
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
clap_controls
;

main_window = Window.new("Drum Synth Controller", Rect(0,0,800,530));
main_window.front;

/******************************************
 * H KICK A
 * 32 33 34 35 36 37 38
 */
hakick_panel = HLayoutView(main_window, Rect(10,30,305,75));
hakick_panel.background_(Color.fromHexString("#FF9955"));

hakick_lbl = StaticText(main_window, Rect(10, 10, 150, 20));
hakick_lbl.string = "HARD KICK A";

hakick_controls = [];
hakick_controls.add(Button(hakick_panel,Rect(0,0,15,10)).action_({ Synth("nun_kick_a"); }));
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
hbkick_controls.add(Button(hbkick_panel,Rect(0,0,15,10)).action_({ Synth("nun_kick_b"); }));
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
skick_controls.add(Button(skick_panel,Rect(0,0,15,10)).action_({ Synth("nun_kick_c"); }));
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

adrum_controls.add(Button(adrum_panel,Rect(0,0,15,10)).action_({ Synth("nun_drum_a"); }));
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
bdrum_controls.add(Button(bdrum_panel,Rect(0,0,15,10)).action_({ Synth("nun_drum_b"); }));
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
cdrum_controls.add(Button(cdrum_panel,Rect(0,0,15,10)).action_({ Synth("nun_drum_c"); }));
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
asnare_controls.add(Button(asnare_panel,Rect(0,0,15,10)).action_({ Synth("nun_snare_a"); }));
View(asnare_panel,Rect(0,0,5,10));// spacer

// dec1
asnare_controls.add(EZKnob(asnare_panel, 40@74, "dec1", [0.05, 2].asSpec.default = 0.2, { |widget|
	var bus = Bus.new('control',82,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq1
asnare_controls.add(EZKnob(asnare_panel, 40@74, "freq1", [40,400].asSpec.default = 138, { |widget|
	var bus = Bus.new('control',83,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// freq2
asnare_controls.add(EZKnob(asnare_panel, 40@74, "freq1", [40,400].asSpec.default = 261, { |widget|
	var bus = Bus.new('control',84,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// filt
asnare_controls.add(EZKnob(asnare_panel, 40@74, "filt", \freq.asSpec.default = 7000, { |widget|
	var bus = Bus.new('control',85,1,s);
	bus.set(widget.value);
},layout:\vert2, initAction:true ));
// dist
asnare_controls.add(EZKnob(asnare_panel, 40@74, "dist", [0, 1].asSpec.default = 0, { |widget|
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
bsnare_controls.add(Button(bsnare_panel,Rect(0,0,15,10)).action_({ Synth("nun_snare_b"); }));
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
clap_panel.background_(Color.fromHexString("#5599CC"));

clap_lbl = StaticText(main_window, Rect(325, 310, 150, 20));
clap_lbl.string = "HAND CLAP";

clap_controls = [];
clap_controls.add(Button(clap_panel,Rect(0,0,15,10)).action_({ Synth("nun_clap"); }));
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
/// end
)
