(
SynthDef(\sliceSynth,
{
	arg bufNum, div = 16, slice = 0, gateRatio = 1, stutter = 1;
	var needle, snd, addFrame, sliceDur, bufDur;

	bufDur = BufFrames.ir(bufNum);
	sliceDur = bufDur / div;
	addFrame = (slice * sliceDur);
	needle = Phasor.ar(0, BufRateScale.kr(bufNum), 0, bufDur);
	snd = BufRd.ar(2, bufNum, (needle % (sliceDur / stutter)) + addFrame);

	FreeSelf.kr(needle > (sliceDur / gateRatio));
	OffsetOut.ar(0, snd);

}).add;
)

b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/PImpler/44/akpen_1_1_130-40.wav"); //load a loop

(
~glSlice = 0; //keeping the state
~div = 16;
~slice = {  ~glSlice = ~glSlice + 1; ~glSlice % ~div; };
~gateRatio = 1;
~stutter = 1;

fork
({
	loop
	({
		Synth(\sliceSynth,
			[
				\bufNum, b,
				\div, ~div.value,
				\slice, ~slice.value,
				\gateRatio, ~gateRatio.value,
				\stutter, ~stutter.value
			]);

		(b.duration / ~div).wait;

	});
});
)

//perform

~gateRatio = { rrand(0.25, 4).round(0.25) }
~stutter = { exprand(0.25, 1) }
~div = 16
~slice = { ~div.rand; }
~div = 1
~gateRatio = { rrand(0.5, 8).round(0.25) }


s.makeGui;