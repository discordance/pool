

(
a = Array.fill(32, { 2.bilinrand });
b = Array.fill(32, { 2.bilinrand });
)


g = 0;
t = TempoClock.new((120/60), 0, 0);
t.beats = 0;
t.beats;

t.schedAbs(t.nextBar, {
	g = (g+1);
	if(a.at((g%32)) > 0,{
		Synth("kickDrum",[\gate,1]);
	});
		if(b.at((g%32)) > 0,{
		Synth("cymbal808_ryan",[\gate,1]);
	});
	4/32;
});



t.clear;

(
SynthDef("kickDrum", { arg gate=0;
        var daNoise,daOsc,env1,env2,env3;
        env1=Env.perc(0.001,1,80,-20);
        env2=Env.perc(0.001,1,1,-8);
        env3=Env.perc(0.001,1,80,-8);
        daNoise=LPF.ar(WhiteNoise.ar(1),EnvGen.kr(env1,gate)+20);
        daOsc=LPF.ar(SinOsc.ar(EnvGen.kr(env3,gate)+20),800);
        Out.ar(0,Pan2.ar(Mix.ar([daNoise,daOsc]), 0, EnvGen.kr(env2,gate,doneAction: 2)););
}).add();

SynthDef(\cymbal808_ryan, {
	arg out=0, baseFreq = 300, time = 250, amp=0.1;
	//var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	//var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
	var signal, pulseEnv;

	pulseEnv = EnvGen.ar(Env.new([1.0, 0.6], [time], [-0.5]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width:0.55)) * 0.9);
	signal = RLPF.ar(signal, 7000, 0.6);
	signal = RHPF.ar(signal, 6800, 1.5);
	signal = RHPF.ar(signal, 6800, 1.5);
	signal = RHPF.ar(signal, 1200, 1.5);
	signal = signal + FreeVerb.ar(signal);
	signal = signal * EnvGen.ar(Env.new([0, 1, 0.4, 0, 0], [2, time, 50, 500], [0, -0.5, 0, -50]), timeScale:(1/1000), doneAction:2);
	signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
	OffsetOut.ar(out, signal*4*amp);
}).add();

)


