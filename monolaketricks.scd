

~hat = Buffer.read(s,"/Users/nunja/Documents/AudioLib/freesound/cymb/A#_cymbalpoint1.wav");

(
SynthDef("smp_closedHat",{|out = 0, b = 0, decay = 0, t_trig = 0|
	var sig = [0,0], env1, env2, phzr, nz,
	numframes = BufFrames.kr(b),
	rscale = BufRateScale.kr(b);

	nz = LFNoise0.kr(1000).range(-0.05,0.05);
	env1 = EnvGen.ar(Env.perc(decay.linlin(0,1,0.01,0.06), decay.linlin(0,1,0.04,0.3), 1, -2), t_trig);
	env2 = EnvGen.ar(Env.perc(0.001, 0.1, 1, -3), t_trig);
	phzr = Phasor.ar(0, rscale*0.98, 0, numframes/12);
	sig = Decimator.ar(LPF1.ar(BufRd.ar(2, b, phzr, 1, 4) * env2, 12000), 22050, 8);
	sig = sig+PlayBuf.ar(2, b, rscale+nz, t_trig, 0, 1)*env1;
	sig = HPF.ar(sig, 100);
	Out.ar(out, sig);
}).add(completionMsg:{
	x = Synth.new("smp_closedHat", [\t_trig, 1]);
});
)



SynthDef("smp_openHat",{|out = 0, b = 0, decay = 0, t_trig = 0|

}).add(completionMsg:{
	y = Synth.new("smp_openHat", [\t_trig, 1]);
});

(
a = Array.fill(16,1);
g = 0;
t = TempoClock.new((230/60), 0, 0);
t.beats = 0;
t.beats;
)

(
t.schedAbs(t.nextBar, {
	g = (g+1);
	if(a.at((g%16)) > 0,{
		{
			x.set(\t_trig, 1, \decay, 0.1);
		}.fork
	});
	4/16;
});
)



Server.local.makeGui;


