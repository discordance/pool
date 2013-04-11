SynthDef(\peep,{|freq=100|
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.perc(0.001,0.25), doneAction:2);
	Out.ar(0, snd ! 2);
}).add;
w = Window("sequencer", Rect(0, 0, 400, 200)).front;
a = 0!16!8;
a.do{ |rows, i|
	rows.do{ |cell, j|
		Button(w, Rect(j*25, i*25, 25, 25))
		.states_([
			["-", Color.black, Color.white],
			["O", Color.white, Color.black],
		])
		.action_{ |v|
			a[i][j] = v.value;
		};
	};
};
Ppar(a.collect({|c, r| Pbind(
	\instrument, \peep,
	\freq, Pif(Pseq(a[r], inf).coin, 100+(a.size-100*r), \rest),
	\dur, 0.25
)}), inf).play;