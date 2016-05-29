s.boot; //boot the default server

(//4 local servers
~servers = 4.collect({|cnt| Server.new("s"++cnt, NetAddr("localhost", 51000 + cnt), Server.default.options); });
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
		// mods fm7
		m1  = 0,  m2 = 0,  m3 = 0,  m4 = 0,  m5 = 0,  m6 = 0,
		m7  = 0,  m8 = 0,  m9 = 0, m10 = 0, m11 = 0, m12 = 0,
		m13 = 0, m14 = 0, m15 = 0, m16 = 0, m17 = 0, m18 = 0,
		m19 = 0, m20 = 0, m21 = 0, m22 = 0, m23 = 0, m24 = 0,
		m25 = 0, m26 = 0, m27 = 0, m28 = 0, m29 = 0, m30 = 0,
		m31 = 0, m32 = 0, m33 = 0, m34 = 0, m35 = 0, m36 = 0,
		// env
		env1_a = 0.01, env1_d = 0.3, env1_s = 0.5, env1_r = 1,
		env2_a = 0.01, env2_d = 0.3, env2_s = 0.5, env2_r = 1,
		env3_a = 0.01, env3_d = 0.3, env3_s = 0.5, env3_r = 1,
		env4_a = 0.01, env4_d = 0.3, env4_s = 0.5, env4_r = 1,
		env5_a = 0.01, env5_d = 0.3, env5_s = 0.5, env5_r = 1,
		env6_a = 0.01, env6_d = 0.3, env6_s = 0.5, env6_r = 1;

		var ctls, mods, out = 0;
		var t_ktrig = Impulse.ar(0);
		ctls = [
			[f1, p1, EnvGen.kr(Env.adsr(env1_a, env1_d, env1_s, env1_r), t_ktrig)],
			[f2, p2, EnvGen.kr(Env.adsr(env2_a, env2_d, env2_s, env2_r), t_ktrig)],
			[f3, p3, EnvGen.kr(Env.adsr(env3_a, env3_d, env3_s, env3_r), t_ktrig)],
			[f4, p4, EnvGen.kr(Env.adsr(env4_a, env4_d, env4_s, env4_r), t_ktrig)],
			[f5, p5, EnvGen.kr(Env.adsr(env5_a, env5_d, env5_s, env5_r), t_ktrig)],
			[f6, p6, EnvGen.kr(Env.adsr(env6_a, env6_d, env6_s, env6_r), t_ktrig)],
		];
		mods = [
			m1  ,  m2 ,  m3 ,  m4 ,  m5 ,  m6 ,
			m7  ,  m8 ,  m9 , m10 , m11 , m12 ,
			m13 , m14 , m15 , m16 , m17 , m18 ,
			m19 , m20 , m21 , m22 , m23 , m24 ,
			m25 , m26 , m27 , m28 , m29 , m30 ,
			m31 , m32 , m33 , m34 , m35 , m36 ,
		];
		out = FM7.ar(ctls, mods);
		out = Mix.ar(out);
		DetectSilence.ar(out, doneAction: 2);
		Out.ar(outBus, out* -12.dbamp);
});
if(a.species == GAPmatch, { a.cleanUp; });
a = GAPmatch.new
(
400, //poolSize
~sDef, //our clueless synthdef
"/Users/nunja/Documents/Audiolib/8000-WAVS.WAV/SNARES/DM-SNA 0139.wav", //provide your sample here
[
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
	\m1,
	/*\m2,
	\m3,
	\m4,
	\m5,
	\m6,*/
	\m7,
	/*\m8,
	\m9,
	\m10,
	\m11,
	\m12,*/
	\m13,
	/*\m14,
	\m15,
	\m16,
	\m17,
	\m18,*/
	\m19,
	/*\m20,
	\m21,
	\m22,
	\m23,
	\m24,*/
	\m25,
	/*\m26,
	\m27,
	\m28,
	\m29,
	\m30,*/
	\m31,
	/*\m32,
	\m33,
	\m34,
	\m35,
	\m36,*/
	\env1_a,
/*	\env1_d,
	\env1_s,
	\env1_r,*/
	\env2_a,
/*	\env2_d,
	\env2_s,
	\env2_r,*/
	\env3_a,
/*	\env3_d,
	\env3_s,
	\env3_r,*/
	\env4_a,
/*	\env4_d,
	\env4_s,
	\env4_r,*/
	\env5_a,
/*	\env5_d,
	\env5_s,
	\env5_r,*/
	\env6_a,
/*	\env6_d,
	\env6_s,
	\env6_r,*/
], //synth parameters
{[
	// base freq
	rrand(30,12000),
	rrand(30,12000),
	rrand(30,12000),
	rrand(30,12000),
	rrand(30,12000),
	rrand(30,12000),
	// phases
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	rrand(0,2pi),
	// mods
	rrand(0,6),
	/*rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),*/
	rrand(0,6),
	/*rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),*/
	rrand(0,6),
	/*rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),*/
	rrand(0,6),
	/*rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),*/
	rrand(0,6),
	/*rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),*/
	rrand(0,6),
	/*rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),
	rrand(0,6),*/
	// env
	exprand(0.001,0.5),
/*	exprand(0.01,1),
	exprand(0,1),
	exprand(0,1),*/
	exprand(0.001,0.5),
/*	exprand(0.01,1),
	exprand(0,1),
	exprand(0,1),*/
	exprand(0.001,0.5),
/*	exprand(0.01,1),
	exprand(0,1),
	exprand(0,1),*/
	exprand(0.001,0.5),
/*	exprand(0.01,1),
	exprand(0,1),
	exprand(0,1),*/
	exprand(0.001,0.5),
/*	exprand(0.01,1),
	exprand(0,1),
	exprand(0,1),*/
	exprand(0.001,0.5),
/*	exprand(0.01,1),
	exprand(0,1),
	exprand(0,1),*/
]}, //random values for parameters limited in a range (function returning array)
100, //number of threads per server
~servers //our servers
);
)


// 6.do{|i|
// 	('exprand(0.001,0.5),').postln;
// 	('exprand(0.01,1),').postln;
// 	('exprand(0,1),').postln;
// 	('exprand(0,1),').postln;
// }

