/* test multi buff */



~buf_a = Buffer.read(s,"/Users/nunja/Documents/AudioLib/supercollider/loop/aphex.aif");
~buf_b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/supercollider/loop/noisy.aif");

(
x = {|buffer = 0, t_fade = 0|
	var percent, ftime = 0.13;
	var a_snd, a_aph, a_tr, a_env;
	var b_snd, b_aph, b_tr, b_env;
	var sig, fade_env;
	var rate = 1;

	rate = MouseX.kr(0,2);
	buffer = buffer.lag(0.01); // delay buffer change to trigger env beforehand
	ftime = ftime/rate;
	percent = ftime/(BufFrames.kr(buffer)/s.sampleRate)*rate;
	a_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
	b_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
	b_aph = (b_aph+(BufFrames.kr(buffer)/2)).wrap(0,BufFrames.kr(buffer));

	a_tr = ((a_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
	b_tr = ((b_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
	a_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,1),a_tr);
	b_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,1),b_tr);
	fade_env = 1-EnvGen.kr(Env.linen(0,0,0.5,1,1),t_fade);

	a_snd = BufRd.ar(2, buffer, a_aph) * a_env * 0.7;
	b_snd = BufRd.ar(2, buffer, b_aph) * b_env * 0.7;
	sig = (a_snd+b_snd) * fade_env;
	Out.ar(0,HPF.ar(Compander.ar(sig,sig,-16.dbamp,1,1.15,0.01,0.2),200));

}.play;
)

(
x.set(\buffer,~buf_b);
x.set(\t_fade,1);
)
