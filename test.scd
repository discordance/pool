SynthDef(\nun_kick_b,{
	arg out=0, amp=0.6, pan=0,
	click_rate = 110, shp1 = 50, shp2 = 20, decay = 0.26;
	var env0, env1, env1m, sig;


	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, decay], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([click_rate, shp1, shp2], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	sig = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m, 0.5, env0);

	sig = sig * 1.2;
	sig = sig.clip2(1);

	Out.ar(out, Pan2.ar(sig * amp));

}).add;

x = Synth("nun_kick_b"); // perfect click at the beginning
