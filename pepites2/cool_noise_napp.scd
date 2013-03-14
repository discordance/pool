(
SynthDef("pulse",{ arg freq,delayTime,amp = 1.0,attack = 0.01;
	var out,out2,env;
	env = EnvGen.kr(Env.perc(attack, 1, 5, 10),doneAction: 2);
	z = SinOsc.ar(freq,0,0.7);
	a = Pan2.ar(ToggleFF.ar(TDelay.ar(z,delayTime)) * SinOsc.ar(freq),
	         SinOsc.kr(3,0), 0.6);
	out = Pan2.ar(z, SinOsc.kr(5,1.0pi),0.7 ) + a;
	out = out * env;
	out = out.clip2(1);

	Out.ar(0,FreeVerb.ar(out,0.7,1.0,0.4, amp));
}).send(s);

SynthDef("droneee", { arg freq = 440, amp = 1.0, outbus = 0, phase = 0;
	var out, env;
	env = EnvGen.kr(Env.sine(10),doneAction: 2);
	out = LFPulse.ar(freq , 0.15);
	out = RLPF.ar(out,SinOsc.kr(0.3, 0, 200, 1500), 0.1);
	out = FreeVerb.ar(out, 0.5, 0.5, 0.5) * env;
	out = Pan2.ar(out, SinOsc.kr(1/10, phase),amp);

    Out.ar(outbus, out);
}).send(s);


SynthDef("bass",{
	arg freq,amp,outbus=0;
	var env,out;
	out = SinOsc.ar(freq,0,amp);
	env = EnvGen.kr(Env.perc(0.5,1,1,0),doneAction: 2);
	out = out*env;
	out = Pan2.ar(out,0);
	Out.ar(outbus,out);


}).send(s);
)


(

p = Prand( [31,40, 45,64,68,69], inf).asStream;
q = Prand( [3,0.7,1,0.5], inf ).asStream;
e = Prand([59,72,76,79,81,88,90],inf).asStream;

t = Task({
		inf.do({

		if( 0.1.coin, {
			Synth("pulse",
			     [\freq,e.value.midicps,
			      \amp,0.07.rand +0.2,
			      \attack,7.0.rand,
			            \delayTime, 0.02;
			            ]);
		   });


		Synth("droneee",
		       [\outBus,0,
		        \freq, p.value.midicps,
		        \amp, (0.02.rand2 + 0.05) * 0.7,
		        \phase,[0,1.5pi].wchoose([0.5,0.5]);
		        ]);
		q.value.wait;

		Synth("bass",[\freq,31.value.midicps,\amp,0.3]);

	            });
});

t.start;
)