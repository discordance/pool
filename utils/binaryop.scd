


(
~dir = "/Users/nunja/Documents/AudioLib/supercollider/os/";
~list = [];
~buffs = [];
~parse_dir = {|dir|
	if(File.type(dir) != \directory,{
		~list = ~list.add(dir);
	},{
		dir = dir ++ "*";
			dir.pathMatch.sort.collect{|file|
				~parse_dir.value(file);
			}
	});
};
~parse_dir.value(~dir);
~list.do{|el,i|
	~buffs = ~buffs.add(Buffer.read(s,el));
};
~buffs[0].bufnum.postln;
~buffs[~buffs.size-1].bufnum.postln;
)

(
{
	|ba = 0, bb = 379|
	var sig1, sig2, fin, fin2, smpl1, smpl2, rnd = 0, rnd2 = 0, imp, clean;
	imp = Dust.ar(MouseY.kr(100,1, 1));
	rnd = TRand.kr(ba,bb,imp);
	rnd2 = TRand.kr(ba,bb,imp);
	smpl1 = PlayBuf.ar(2, rnd, BufRateScale.kr(rnd), 1) *0.15;
	smpl2 = PlayBuf.ar(2, rnd2, BufRateScale.kr(rnd2), 1) *0.15;

	sig1 = (SoundIn.ar(4)*0.5)+SoundIn.ar(6)+smpl1;
	sig2 = SoundIn.ar(5)+SoundIn.ar(7)+smpl2;

	fin = BinaryOpUGen('<', (sig1 < 0) + (Delay2.ar(sig2) > 0), 1);
	fin2 = BinaryOpUGen('==', (sig1 > 0) * (Delay2.ar(sig2) > 0), 1);
	fin = SelectX.ar(MouseX.kr(0,2),[fin,fin2]);
	fin = fin + Delay2.ar(fin);
	fin = fin *0.12;
	fin = DFM1.ar(fin,LFNoise2.kr(100).range(5000,8000)).tanh *0.45;
	fin = fin + (GVerb.ar(fin,100,30,0.42,0.51,-5,-26,-20)*0.005);
	clean = (SoundIn.ar(6)+SoundIn.ar(7)+smpl1);
	fin = Compander.ar(fin,clean,-16.dbamp,1,1.3,0.01,0.3) + (clean*MouseY.kr(1,0));
	Pan2.ar(fin+(SoundIn.ar(4)*1.2!2),0);
}.play();
)

s.prepareForRecord;
s.record("test");
s.stop;

(
play {
	var t = PulseCount.ar(Impulse.ar(8000));
	HPF.ar(
(
((t * 1) & (t >> 8)) |
((t * 6) & (t >> 3))
- 1 % LFNoise2.kr(0.1).range(64,)
) / 63-1 * 6
, 80
	).tanh * 0.12 ! 2
}
)


SynthDef(\dataverb, { |t_trig, freq, amp = 0.5 att = 0.1, dec = 0.8, rtime = 0.04|
    var steps = 64, d, a, w, f, sig, controlEnv;
    d = (1..steps - 1).collect({|n| rtime * n}).addFirst(0);
    a = (2..steps).collect({|n| amp / n}).addFirst(amp);
    w = [0.5, 0.6, 0.7, 0.4];
    f = [freq, freq * 0.999, freq * 1.001, freq / 2, freq * 1.5];
    sig = Mix.new(
        Pulse.ar(f, w, mul: EnvGen.kr(Env.perc(att, dec), DelayN.kr(t_trig, d, d), a))
    );
    controlEnv = EnvGen.kr(Env.new([0, 0], [d.last + att + dec]), doneAction: 2);
    Out.ar(0, sig!2);
}).add;

Synth.new(\dataverb, [\t_trig,1,\freq,1000]);


play{a=HPF.ar(ar(PinkNoise,5e-3),10)*Line.kr(0,1,9);ar(GVerb,({|i|ar(Ringz,a*LFNoise1.kr(0.05+0.1.rand),55*i+60,0.2)}!99).sum,70,99).tanh*0.2}