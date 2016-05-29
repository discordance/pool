
b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/akpen_1_3_130-40.wav", 0,-1);
//b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/akpen_2_1_130-40.wav", 0,-1);
//b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/tmort.wav", 0,-1);
(
SynthDef(\looper, {|beats = 0, rate = 1, envlen = 1, out = 0, buffer = 0, t_tick = 0|
	var track_snd, track_phasor;
	var track_env;
	var selected_scale = 1;
	var len_scale = 1;
	var beat_divs = [0.25, 0.5, 1, 2, 4];
	var offset_val = 0;
	var track_impulse = 1;
	// metronom debug
	var metro = 0;

	var beat_impulse = PulseDivider.kr(t_tick, 24, 0);
	var bar_impulse = PulseDivider.kr(t_tick, 96, 0);
	// metronom debug
	metro = EnvGen.ar(Env.perc(0.01,0.5),beat_impulse) * SinOsc.ar(3000,0,0.3) ! 2;
	metro = metro + EnvGen.ar(Env.perc(0.01,0.5),bar_impulse) * SinOsc.ar(1800,0,0.15) ! 2;

	offset_val = BufFrames.kr(buffer)/8;

	len_scale = Latch.kr(Select.kr(MouseX.kr(0,beat_divs.size),beat_divs),bar_impulse);
	envlen = len_scale*envlen;
	track_impulse = PulseDivider.kr(t_tick, 24*len_scale, 0);
	track_snd = PlayBufCF.ar(2, buffer,  BufRateScale.kr(buffer)*rate, track_impulse, MouseY.kr(0,7).floor*offset_val, 1, 0.05, 3);

	Out.ar(out, metro+track_snd);
}).add;
)

(
~syh = Synth.new("looper", [\buffer, 0 ]);
)

// try to smoth out the tempo by 96 moving averaging
(
~barInSamples = {|tempo, sr, mult|
	(((60000.0*4*sr)/tempo)/1000.0)*mult;
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
	~syh.set(\beats, t.beats, \rate,(tempo/130.4), \envlen, 1*(60/tempo));
	1/24;
});
)
t.tempo = (90/60);

1*(130/120);

(
var floor = 0;
a = Signal.newClear(1024);
a.waveFill({ arg x, old, i;
	if(i%64 == 0, {
		floor = 9.rand;
	});
	floor
}, 0, 1);
a.plot;
)





