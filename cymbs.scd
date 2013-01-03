(
x = {

	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res;

	locutoffenv = EnvGen.ar(Env.perc(0.25, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	freqs  = {exprand(900, 20000)}.dup(40);
	res    = Ringz.ar(lodriver + hidriver, freqs).mean.dup;
	res    = (res*0.3) + (PinkNoise.ar()*0.8) * EnvGen.kr(Env.perc(0, 0.5), doneAction:2);
}.play;
)

(
10.do({ arg i;
	[1, 2, 3, 4].pyramid(i + 1).asCompileString.postln;
});
)
