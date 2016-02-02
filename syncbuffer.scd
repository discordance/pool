
b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/akpen_1_3_130-40.wav", 0,-1);
//b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/akpen_2_1_130-40.wav", 0,-1);

(
SynthDef(\looper, {|rate = 1, envlen = 1, out = 0, buffer = 0, t_tick = 0|
	var track_snd, track_phasor;
	var track_env;
	var selected_scale = 1;
	var len_scale = 1;
	var beat_divs = [0.25, 0.5, 1, 2, 4];
	var track_impulse = 0;

	var beat_impulse = PulseDivider.kr(t_tick, 24, 0);
	var bar_impulse = PulseDivider.kr(t_tick, 96, 0);

	len_scale = Latch.kr(Select.kr(MouseX.kr(0,beat_divs.size),beat_divs),beat_impulse);
	envlen = len_scale*envlen;
	track_impulse = PulseDivider.kr(t_tick, 24*len_scale, 0);
	track_env = EnvGen.ar(Env([0, 0, 1, 1, 0], [0, 0.05, (envlen-0.05), 0.01]), track_impulse+HPZ2.kr(len_scale));
	track_phasor = Phasor.ar(track_impulse, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
	track_snd = BufRd.ar(2, buffer, track_phasor, 0) * 1;
	track_snd = track_snd * track_env;
	//track_snd = PinkNoise.ar(0.3) * Amplitude.ar(track_snd, 0.001, 0.01);
	Out.ar(out,track_snd);
}).add;
)

(
~syh = Synth.new("looper", [\buffer, 0 ]);
)

// try to smoth out the tempo by 96 moving averaging
(
~barInSamples = {|tempo, sr|
	(((60000.0*4*sr)/tempo)/1000.0);
};
~bufferLengthSec = {|buffer, rate|
	(buffer.numFrames/buffer.sampleRate)*(1+(1-rate));
};
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
		if(mem.size >= 48, {
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
t = TempoClock.new((120/60), 0, 0);
t.beats = 0;
t.schedAbs(t.nextBar, {
	var time, ival, tempo;
	~syh.set(\t_tick,1);

	time = Main.elapsedTime;
	ival = (time - l)*24;
	tempo = (60/ival);
	l = time;
	tempo = ~smoothBpm.value(tempo);
	~syh.set(\rate,(tempo/130.4), \envlen, 1*(60/tempo));
	1/24;
});
)
t.tempo = (130/60);

1*(60/120);



