s.boot; //boot the default server

(//6 local servers
~servers = 6.collect({|cnt| Server.new("s"++cnt, NetAddr("localhost", 51000 + cnt), Server.default.options); });
fork
({
	~servers.do
	({|srv|

		srv.boot;
		1.wait;
	});

	~servers.do(_.makeWindow);
}, clock: AppClock);
)

(
~sDef = SynthDef(\fmSynth,
	{//an fm7 based synthesizer
		arg outBus,
		//fm7
		f1 = 100, f2 = 100, f3 = 100, f4 = 100, f5 = 100, f6 = 100,
		p1 = 0, p2 = 0, p3 = 0, p4 = 0, p5 = 0, p6 = 0,
		a1 = 1, a2 = 1, a3 = 1, a4 = 1, a5 = 1, a6 = 1,
		// mods fm7
		m1  = 0,  m2 = 0,  m3 = 0,  m4 = 0,  m5 = 0,  m6 = 0,
		// indexes
		i1 = 0, i2 = 1, i3 = 2, i4 = 3, i5 = 4, i6 = 5,
		/*
		m7  = 0,  m8 = 0,  m9 = 0, m10 = 0, m11 = 0, m12 = 0,
		m13 = 0, m14 = 0, m15 = 0, m16 = 0, m17 = 0, m18 = 0,
		m19 = 0, m20 = 0, m21 = 0, m22 = 0, m23 = 0, m24 = 0,
		m25 = 0, m26 = 0, m27 = 0, m28 = 0, m29 = 0, m30 = 0,
		m31 = 0, m32 = 0, m33 = 0, m34 = 0, m35 = 0, m36 = 0,*/
		// env
		env_a = 0.01, env_r = 1, env_c = -4,
		// swipe
		swipeR1 = 1, swipeDec1 = 0.001,
		swipeR2 = 1, swipeDec2 = 0.001,
		swipeR3 = 1, swipeDec3 = 0.001,
		swipeR4 = 1, swipeDec4 = 0.001,
		swipeR5 = 1, swipeDec5 = 0.001,
		swipeR6 = 1, swipeDec6 = 0.001,
		// noise
		noiseAmp = 2, noiseDecay = 0.07, noiseFreq = 200, noiseRQ = 0.15;

		var ctls, mods, noise = 0, out = 0;
		var t_ktrig = Impulse.ar(0), noiseEnv;
		ctls = [
			[EnvGen.kr(Env([0, f1*swipeR1, f1], [0, swipeDec1]), t_ktrig), p1, a1],
			[EnvGen.kr(Env([0, f2*swipeR2, f2], [0, swipeDec2]), t_ktrig), p2, a2],
			[EnvGen.kr(Env([0, f3*swipeR2, f3], [0, swipeDec3]), t_ktrig), p3, a3],
			[EnvGen.kr(Env([0, f4*swipeR2, f4], [0, swipeDec4]), t_ktrig), p4, a4],
			[EnvGen.kr(Env([0, f5*swipeR2, f5], [0, swipeDec5]), t_ktrig), p5, a5],
			[EnvGen.kr(Env([0, f6*swipeR2, f6], [0, swipeDec6]), t_ktrig), p6, a6],
		];
		/*	mods = [
		Select.kr(i1,[0,m1]), Select.kr(i2,[0,m2]), Select.kr(i3,[0,m3]), Select.kr(i4,[0,m4]), Select.kr(i5,[0,m5]), Select.kr(i6,[0,m6]),
		Select.kr(i6,[0,m1]), Select.kr(i5,[0,m2]), Select.kr(i4,[0,m3]), Select.kr(i3,[0,m4]), Select.kr(i2,[0,m5]), Select.kr(i1,[0,m6]),
		Select.kr(i1,[0,m1]), Select.kr(i2,[0,m2]), Select.kr(i3,[0,m3]), Select.kr(i4,[0,m4]), Select.kr(i5,[0,m5]), Select.kr(i6,[0,m6]),
		Select.kr(i6,[0,m1]), Select.kr(i5,[0,m2]), Select.kr(i4,[0,m3]), Select.kr(i3,[0,m4]), Select.kr(i2,[0,m5]), Select.kr(i1,[0,m6]),
		Select.kr(i1,[0,m1]), Select.kr(i2,[0,m2]), Select.kr(i3,[0,m3]), Select.kr(i4,[0,m4]), Select.kr(i5,[0,m5]), Select.kr(i6,[0,m6]),
		Select.kr(i6,[0,m1]), Select.kr(i5,[0,m2]), Select.kr(i4,[0,m3]), Select.kr(i3,[0,m4]), Select.kr(i2,[0,m5]), Select.kr(i1,[0,m6]),
		];*/
		/*		mods = [
		m1  ,  m2 ,  m3 ,  m4 ,  m5 ,  m6 ,
		m7  ,  m8 ,  m9 , m10 , m11 , m12 ,
		m13 , m14 , m15 , m16 , m17 , m18 ,
		m19 , m20 , m21 , m22 , m23 , m24 ,
		m25 , m26 , m27 , m28 , m29 , m30 ,
		m31 , m32 , m33 , m34 , m35 , m36 ,
		];*/
		mods = [
			0  , 0  , m1 ,  0  ,  0  ,  i1 ,
			i2 , 0  , 0  ,  m2 ,  0  ,  0  ,
			0  , i3 , 0  ,  0  ,  m3 ,  0  ,
			0  , 0  , i4 ,  0  ,  0  ,  m4 ,
			m5 , 0  , 0  ,  i5 ,  0  ,  0  ,
			0  , m6 , 0  ,  0  ,  i6 ,  0  ,
		];
		noiseEnv = EnvGen.ar(Env.perc(0.01, noiseDecay, noiseAmp, env_c), t_ktrig);
		noise = BPF.ar(WhiteNoise.ar(1) * noiseEnv, noiseFreq, noiseRQ);
		out = FM7.ar(ctls, mods);
		out = Mix.ar(out*EnvGen.ar(Env.perc(env_a,env_r,1,env_c))) + (noise * noiseAmp);
		DetectSilence.ar(out, doneAction: 2);
		Out.ar(outBus, out* -12.dbamp);
});
if(a.species == GAPmatch, { a.cleanUp; });
a = GAPmatch.new
(
720*2, //poolSize
~sDef, //our clueless synthdef
"/Users/nunja/Documents/Audiolib/8000-WAVS.WAV/CONGAS/DM-CON A04.wav", //provide your sample here
[
	\env_a,
	\env_r,
	\env_c,

	\swipeR1,
	\swipeDec1,
	\swipeR2,
	\swipeDec2,
	\swipeR3,
	\swipeDec3,
	\swipeR4,
	\swipeDec4,
	\swipeR5,
	\swipeDec5,
	\swipeR6,
	\swipeDec6,

	\noiseAmp,
	\noiseDecay,
	\noiseFreq,
	\noiseRQ,
	\f1,
	\f2,
	\f3,
	\f4,
	\f5,
	\f6,
	\p1,
	\p2,
	\p3,
	\p4,
	\p5,
	\p6,
	\a1,
	\a2,
	\a3,
	\a4,
	\a5,
	\a6,
	\m1,
	\m2,
	\m3,
	\m4,
	\m5,
	\m6,
	\i1,
	\i2,
	\i3,
	\i4,
	\i5,
	\i6,
	/*\m7,
	\m8,
	\m9,
	\m10,
	\m11,
	\m12,
	\m13,
	\m14,
	\m15,
	\m16,
	\m17,
	\m18,
	\m19,
	\m20,
	\m21,
	\m22,
	\m23,
	\m24,
	\m25,
	\m26,
	\m27,
	\m28,
	\m29,
	\m30,
	\m31,
	\m32,
	\m33,
	\m34,
	\m35,
	\m36,*/
], //synth parameters
{[
	// env
	exprand(0.001, 0.2),
	exprand(0.1, 4.0),
	rrand(-10, 10),
	//swipe
	exprand(0.9, 2), //
	exprand(0.001, 0.1), //
	exprand(0.9, 2), //
	exprand(0.001, 0.1), //
	exprand(0.9, 2), //
	exprand(0.001, 0.1), //
	exprand(0.9, 2), //
	exprand(0.001, 0.01), //
	exprand(0.9, 2), //
	exprand(0.001, 0.01), //
	exprand(0.9, 2), //
	exprand(0.001, 0.01), //
	// noise
	rrand(0, 4.0), //noiseAmp
	exprand(0.01, 4), //noiseDecay
	exprand(1, 20e3), //noiseFreq
	rrand(0.01, 0.99), //noiseRQ
	// base freq
	rrand(30.0,16000.0),
	rrand(30.0,16000.0),
	rrand(30.0,16000.0),
	rrand(30.0,16000.0),
	rrand(30.0,16000.0),
	rrand(30.0,16000.0),
	// phases
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	// amps
	rrand(0,2.0),
	rrand(0,2.0),
	rrand(0,2.0),
	rrand(0,2.0),
	rrand(0,2.0),
	rrand(0,2.0),
	// mods
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	// idexs
	rrand(0.0,2.0),
	rrand(0.0,2.0),
	rrand(0.0,2.0),
	rrand(0.0,2.0),
	rrand(0.0,2.0),
	rrand(0.0,2.0),
	/*rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0.0,6.0),
	rrand(0,1),
	rrand(0.0,6.0),*/
]}, //random values for parameters limited in a range (function returning array)
30, //number of threads per server
~servers //our servers
);
)


// 6.do{|i|
// 	('exprand(0.001,0.5),').postln;
// 	('exprand(0.01,1),').postln;
// 	('exprand(0,1),').postln;
// 	('exprand(0,1),').postln;
// }

20e3