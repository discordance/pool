/**
 * NUNJA Sample Station v0.1
 * defs.scd
        _
        [ ]
       (   )
        |>|
     __/===\__
    //| o=o |\\
  <]  | o=o |  [>
      \=====/
     / / | \ \
    <_________>

 */

~init_defs = {


	/**
	* Os Mixer
	*/
	SynthDef(\nun_os_mixer,{|in, out, fx|
		var output, input = In.ar(in,2);
		var dly_vol = 0, rev_vol = 0, shape_vol = 0;
		// delay
		dly_vol = [0.0, 1.0].asSpec.map(In.kr(2).lag(0.1));
		rev_vol = [0.0, 1.0].asSpec.map(In.kr(3).lag(0.1));
		shape_vol = [0.0, 1.0].asSpec.map(In.kr(4).lag(0.1));
		Out.ar(fx,input*dly_vol);
		Out.ar(fx+2,input*rev_vol);
		Out.ar(fx+4,input*shape_vol);
		Out.ar(out, input);
	}).add;
	/**
	* Final Leveller
	*/
	SynthDef(\nun_leveler,{|in, out, thresh = -10, preamp = 0.5, amp = 0.5|
		var output, input = In.ar(in,2)*preamp;
		output = Compander.ar( input, input, thresh.dbamp, 1, 0.3, 0.01,0.1);
		Out.ar(out,output*amp);
	}).add;

	/**
	* Delay Dub
	*/
	SynthDef(\nun_dubecho,{|in, out, vol = 1, length = 1, fb = 0.8, sep = 0.012|
		var input = In.ar(in, 2);
		var feedback = LocalIn.ar(2);
		var output = LeakDC.ar(feedback*fb + input);
		output = HPF.ar(output, 400);
		output = LPF.ar(output, 5000);
		output = output.tanh;
		//vol.poll;
		//vol = [0.0, 1.0].asSpec.map(In.kr(0).lag(0.1));
		LocalOut.ar(
			DelayC.ar(output*vol, 1,
				LFNoise2.ar(0.2).range([length,length+SinOsc.kr(0.1).range(0,0.012)],[length+sep,length])
			).reverse
		);
		Out.ar(out, output);
	}).add;

	SynthDef(\nun_reverb_a, {
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

	/**
	* DRUM Sampler
	*/
	SynthDef(\nun_drsampler, {
		arg out = 0, buf_bounds = #[0,0], decay = 5, rate = 1, freq = 20000, t_trig = 0, vol = 1;
		var sig, enva, rndsst, rate_mod,
		master_env, a, b;

		//rate_mod = [0.1, 1.9].asSpec.map(In.kr(2).lag(0.1));
		//rate = rate_mod * rate;
		//decay = [0.05, 5, \exp].asSpec.map(In.kr(3).lag(0.1));
		enva = EnvGen.ar(Env.perc(0.01, decay, 1, -4),t_trig);

		sig = 0;
		// random buffers, a is the lead
		a = buf_bounds[0];
		b = TRand.kr(buf_bounds[1],buf_bounds[1]+1,t_trig).floor;
		rndsst = TRand.kr(0,(BufFrames.kr(b) * 0.9).ceil, t_trig);
		master_env = EnvGen.ar(Env.perc(0.01,decay*1.1),t_trig);
		sig = PlayBuf.ar(2, a, BufRateScale.kr(a)*rate, trigger: t_trig) * enva;
		//Pitch.kr(sig).poll;
		sig = sig + PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, trigger: t_trig, startPos: rndsst ) * enva;

		// master env
		sig = sig * master_env;

		sig = LeakDC.ar(sig);
		// filter
		sig = DFM1.ar(sig, freq, 0.5, 3);
		Out.ar(out, sig*vol);

	}).add;

	/**
	* OS Sampler
	*/
	SynthDef(\nun_ossampler, {
		arg out = 0, buf_bounds = #[0,0],
		buf_shape = 1,
		atk = 0.05, decay = 5, drate = 1, rate = 1, freq = 20000;
		var sig, envs,
		master_env, vol = 1,
		a, b,
		// wave shape test
		ws_index
		;

		//envs
		envs = Array.fill(10, {
			EnvGen.ar(Env.new(Array.rand(10, 0.1, 1.0).add(0.0), Array.exprand(9, 0.001, 2),curve:\welch))
		});

		sig = 0;
		// random buffers, a is the lead
		a = IRand(buf_bounds[0],buf_bounds[1]);
		b = IRand(buf_bounds[0],buf_bounds[1]);

		drate = [0.0, 1.0].asSpec.map(In.kr(0).lag(0.1));
		atk = [0.05, 1.0].asSpec.map(In.kr(1).lag(0.1));

		decay = BufDur.kr(a) * 0.8 * drate;
		// master env
		master_env = EnvGen.ar(Env.adsr(atk,decay,1,0.3,1,3), Line.kr(1,-1,decay*1.2), doneAction:2);

		sig = PlayBuf.ar(2, a, BufRateScale.kr(a)*rate) * Select.ar(IRand(0,9),envs);
		sig = sig + Resonz.ar(
			PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, startPos: Rand(0,50))
			* Select.ar(IRand(0,9),envs),Select.ar(IRand(0,9),envs)*20000 + 80);
		// master env
		sig = sig * master_env;

		// waveshape
		//ws_index = LinLin.ar(sig, -1.0, 1.0, 0.0, BufFrames.kr(buf_shape));
		//sig = BufRd.ar(1, buf_shape, ws_index, 0, 4);

		// filter and DC
		sig = LeakDC.ar(sig);
		sig = DFM1.ar(sig, freq, 0.5, 3);

		Out.ar(out, sig*vol);
	}).add;

	SynthDef(\nun_nasty, {
		arg in, out, buff;
		var soundIn, playHead, output, thisIndex;
		soundIn = In.ar(in,2)*2;
		thisIndex = LinLin.ar(soundIn, -1.0, 1.0, 0.0, BufFrames.kr(buff) * LFNoise2.kr(0.6).range(0.0,1.0));
		playHead = BufRd.ar(1, buff, thisIndex, 0, 4) * 3;
		output = LeakDC.ar(playHead)*Amplitude.kr(soundIn);
		output = DFM1.ar(output,14000,0.2,10,0.0008)*0.1;
		Out.ar(out, output!2);
	}).add;

};