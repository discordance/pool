


b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/freesound/chord/A_kk_crd_125-slice#13_2–Копие.wav");


~ezConv = EZConv("/Users/nunja/Documents/AudioLib/impulses/m7_32b_48k/1 Halls 07 Large & Dark Quad.wav",2048*2);

(
SynthDef("help-max", { arg out=0, soundBufnum1=2;
	var inA, chainA, chain, sr = 0.5, bits = 13;
	inA = PlayBuf.ar(1, soundBufnum1, BufRateScale.kr(soundBufnum1)*0.5, loop: 1);

	sr = SinOsc.kr(0.05,0.5).range(0.3,0.7);
	inA = inA.round(0.5**13);
	inA = Latch.ar(inA, Impulse.ar(SampleRate.ir*0.5* sr));
	inA = ~ezConv.ar(inA, leak: 0.5, mul: 0.05);

	chainA = FFT(LocalBuf(2048), inA);
	chain = PV_MagSmear(chainA, SinOsc.kr(0.05).range(0.2,15));
	chain = IFFT(chain).dup;


	Out.ar(out,  0.5 * chain);
}).play(s, [\soundBufnum1, b, \soundBufnum2, 0]);
)
// move that samples

//PV_MagSmear -> cool dub effect
//PV_MagAbove PV_LocalMax -> nice low pass filtering
//PV_MagClip -> kinda weird HP filter
//PV_MagBelow -> kinda weird HP filter
// PV_ConformalMap -> to noisy

// PV_Diffuser -> Subtle phase shift

// PV_RandWipe -> pas mal pour crossfade n'imp et morph

(
var a;
a = Array.fill(64, { arg j; 1.0.rand2 });
8.do({ arg i;
    s.sendMsg(\b_alloc, i, 1024); // allocate table
    // generate array of harmonic amplitudes
    n = (i+1)**2;
    // fill table
    s.performList(\sendMsg, \b_gen, i, \sine1, 7, a.extend(n.asInteger));
});
)


(
SynthDef("help-VOsc",{ arg out=0, bufoffset=0, freq=480;
    var x;
    // mouse x controls the wavetable position
    x = MouseX.kr(0,7);
    Out.ar(out,
		VOsc3.ar(bufoffset+x, freq+[0,1],freq+[0.37,1.1],freq+[0.43, -0.29], 0.1);

    )
}).play(s,[\out, 0, \bufoffset, 0]);
)
