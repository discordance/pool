s = Server.internal;
s.boot;

(
SynthDef("4for8", {
	arg width=2, level=0.5;

        // change to match number of output audio channels
	var numChans = 6;

	var in, amp, pos=0, sig, sig2, sig2pan, out, chain, chainSpec, centroid, freq, hasFreq, freq2, hasFreq2;

	in = In.ar(16);  // input

	# freq, hasFreq = Pitch.kr(
					in,
					ampThreshold: 0.09,
					median: 7);
	freq = freq * hasFreq* 0.01;
	freq.poll;

	chainSpec = FFT(LocalBuf(2048, 1), in);

	centroid = SpecCentroid.kr(chainSpec);

	centroid = ((centroid * 0.0005)-0.3)*10;

	// new possition determined by centroid
	pos = VarLag.kr(
			centroid,
			0.9,
			);  // smooths the position


	// PanAz position of the sound
	sig = PanAz.ar(
		     numChans,
		     in,
		     pos,
		     level,
		     width,
		).scramble;

	chain = FFT({LocalBuf(2048, 1)}.dup(numChans), sig);

	chain = PV_MagFreeze(chain, SinOsc.kr(freq*100));

	sig2 = IFFT(chain);

	sig2pan = SplayAz.ar(
		numChans,
		sig2
	);

	// Mixing wet and dry signal.
	out = sig + sig2pan;
	out = out*0.7;
	Out.ar(0, out);
}).add;

)

(
x = Synth("4for8");
x.set(\width, 5, \level, 0.2)
)