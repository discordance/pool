(
{
	var strike, env, noise, pitch, delayTime, detune;
	strike = Impulse.ar(0.01);
	env = Decay2.ar(strike, 0.008, 0.04);

	pitch = (36 + 54.rand);

	Pan2.ar(
			// array of 3 strings per note
			Mix.ar(Array.fill(3, { arg i;
				// detune strings, calculate delay time :
				detune = #[-0.05, 0, 0.04].at(i);
				delayTime = 1 / (pitch + detune).midicps;
				// each string gets own exciter :
				noise = LFNoise2.ar(3000, env); // 3000 Hz was chosen by ear..
				CombL.ar(noise,		// used as a string resonator
					delayTime, 		// max delay time
					delayTime,			// actual delay time
					6) 				// decay time of string
			})),
			(pitch - 36)/27 - 1 // pan position: lo notes left, hi notes right
		)

}.play
)