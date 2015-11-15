
b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/akpen_1_3_130-40.wav", 0,-1);

(
SynthDef(\looper, {|rate = 1, out = 0, buffer = 0, t_phtrig = 0|
	var a_snd, a_aph;
	var sig;
	var vol = 1;

	a_aph = Phasor.ar(t_phtrig, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
	a_snd = BufRd.ar(2, buffer, a_aph, 0) * 1;

	Out.ar(out,a_snd);
}).add;
)

(
~syh = Synth.new("looper", [\buffer, 0 ]);
)

// try to smoth out the tempo by 96 moving averaging
(
~stdev = {|sample|
	var avg, variance = 0;
	avg = sample.mean;
	variance = sample.collect({|a| (a-avg).pow(2)});
	variance = variance.mean.sqrt;
};
~smoothBpm = {
	var mem = [];
	var stdmem = [];
	{|input|
		var tmp = 0;
		if(mem.size >= 96, {
			mem.removeAt(0);
		});
		if(stdmem.size >= 8, {
			stdmem.removeAt(0);
		});
		mem = mem.add(input);
		tmp = mem.mean.round;
		stdmem = stdmem.add(~stdev.value(mem));
		if(stdmem.mean > (tmp*0.038), {
			mem = [];
		});
		tmp;
	};
}.value();
)

(
l = 0;
g = 0;
t = TempoClock.new((120/60), 0, 0);
t.beats = 0;
t.schedAbs(t.nextBar, {
	~syh.set(\t_phtrig,1);
	g=g+1;
	4;
});
t.schedAbs(t.nextBar, {
	var time, ival, tempo;

	time = Main.elapsedTime;

	ival = (time - l)*24;
	tempo = (60/ival);
	l = time;
	tempo = ~smoothBpm.value(tempo);
	//tempo
	tempo.postln;
	~syh.set(\rate,(tempo/130.4));
	1/24;
});
)
t.tempo = (118/60);

Env.asr(0.001, 1, 1, 256).plot;

