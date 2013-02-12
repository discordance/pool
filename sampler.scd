/**
 * Nunja - Live Oneshots Sampler
 **/

/**
 * Files, Server and Buffers
 */
(
s = Server.local;
s.boot;
s.options.memSize = 655536;
)
(
Buffer.freeAll; // free all buffers
~sampleIndexParse = { |index|
	var arr = [0,0];
	arr[0] = ~buffers[index][0].bufnum;
	arr[1] = ~buffers[index][~buffers[index].size - 1].bufnum;
	arr;
};
~sampleMult = 0;
~samplePer = 8;
~sampleIndex = 0;
~pathArr;
~osPath = "/Users/nunja/Documents/AudioLib/supercollider/os/*";
~pathArr = ~osPath.pathMatch.sort.collect{|file|
	file.insert(file.size,"*");
};
~buffers = Array.fill(~pathArr.size,0);
~pathArr.do{ |file, i|
	~buffers[i] = file.pathMatch.sort.collect{|sfile|
		Buffer.read(s,sfile);
	};
};
)



(
// SynthDef SAMPLER
SynthDef(\nun_ossampler, {
	arg out = 0, buf_bounds = #[0,0];
	var sig, envs, decay,
	master_env, rate = 1, freq = 1000, vol = 1,
	a, b;

	//envs
	envs = Array.fill(10, { EnvGen.ar(Env.new(Array.rand(10, 0.1, 1.0).add(0.0), Array.exprand(9, 0.001, 2),curve:\welch)) });

	sig = 0;
	// random buffers, a is the lead
	a = IRand(buf_bounds[0],buf_bounds[1]);
	b = IRand(buf_bounds[0],buf_bounds[1]);

	decay = [0.06,5].asSpec.map(In.kr(2).lag(0.1));
	rate = [0.05, 0.95].asSpec.map(In.kr(3).lag(0.1));
	vol = [0.0, 1.5].asSpec.map(In.kr(4).lag(0.1));
	// random magic
	master_env = EnvGen.ar(Env.perc(0.05,decay),doneAction:2);

	sig = PlayBuf.ar(2, a, BufRateScale.kr(a),rate: rate) * Select.ar(IRand(0,9),envs);
	sig = sig + Resonz.ar(
		PlayBuf.ar(2, b, BufRateScale.kr(b), rate: rate, startPos: Rand(0,50)) * Select.ar(IRand(0,9),envs),Select.ar(IRand(0,9),envs)*20000 + 80);

	// master env
	sig = sig * master_env;

	// filter
	freq = \freq.asSpec.map(In.kr(1).lag(0.1));
	sig = MoogFF.ar(sig, freq);

	Out.ar(out, sig*vol);
}).add;


)

//~sampleIndex = 1;
//Synth("nun_ossampler", [\buf_bounds, ~sampleIndexParse.value(~sampleIndex)]);

~sampleMult = 1;

/**
 * Midi
 */
(
//list connected ins:
MIDIClient.init;
MIDIClient.sources;
MIDIIn.connectAll;
)

(
MIDIIn.removeFuncFrom(\noteOn, ~sampler_noteOn);
MIDIIn.removeFuncFrom(\control, ~sampler_control);

// bus defaults

~sampler_control = { arg src, chan, num, val;
	var bus = Bus.new('control',num,1,s);
	"CC"+[chan,num,val].postln;
	bus.set(val/127);
};

~sampler_noteOn = { arg src, chan, num, vel;
	if(chan < 9, {

	var idx = (num-36);
	"NoteOn"+[chan,num,vel / 127].postln;
	~sampleIndex = idx + (~samplePer*~sampleMult);
	idx.postln;
	Synth("nun_ossampler", [\buf_bounds, ~sampleIndexParse.value(~sampleIndex), \out, 4]);
	//Synth("cs80lead_mh",[\freq,num.midicps*2,\amp,0.1]); // 320, 280, 420
	});

};

MIDIIn.addFuncTo(\noteOn, ~sampler_noteOn); // add
MIDIIn.addFuncTo(\control, ~sampler_control); // add
)


