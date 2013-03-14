




SynthDef("dummyTone", { |freq|
	var sig;
	sig = FSinOsc.ar(freq,0,0.1) * EnvGen.ar(Env.perc(0.01,2));
	Out.ar(0,sig!2);
}).add;


(
Task({
	var dur=1, ivals, base, i = 0;
	ivals = [0,5,0,1,-2,-2,-2,-2,-7,-2,-7,-2,0];
	base = 68;
	inf.do({
		var note;
		note = base + ivals.wrapAt(i);
		Synth.new("dummyTone",[\freq,note.midicps]);
		dur.wait;
		i = i+1;
	});
}).play(TempoClock.default);
)