

(
{
	var noise, enva, envb, sawa, sawb, sig;

	noise = LatoocarfianN.ar(
    SampleRate.ir/4,
    LFNoise2.ar(0.4,1.5,1.5),
    LFNoise2.ar(0.4,1.5,1.5),
    LFNoise2.ar(0.4,0.5,1.5),
    LFNoise2.ar(0.4,0.5,1.5)
	) * 0.1;
	//noise = noise * EnvGen.ar(Env.perc(0.001, 0.08));

	sawa = SinOsc.ar(EnvGen.ar(Env.new([0,1,0.34,0],[0,0.01,0.1]).range(50,260)));
	sawa = sawa * EnvGen.ar(Env.perc(0.05, 0.2));
	sawa = DFM1.ar(sawa, 3000, 0.9, EnvGen.ar(Env.new([0,1,0.34,0],[0,0.01,0.1]).range(0,10))) * 0.5;
	sawa = sawa ! 2;
}.play;
)

//Env.new([0,1,0.34,0],[0,0.01,0.1]).range(50,220).plot;
