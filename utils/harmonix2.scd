
(
f = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/massacre/long3.wav");

play {
        var input, corrected, freq, hasFreq, autotune, scale, out;
	    var a, k, delfreq, minfreqs, freqs, dry;

        scale = Scale.mixolydian.degrees; // dorian scale
        // can be anything (e.g. SoundIn)
        input = Mix.new(PlayBuf.ar(1,f, BufRateScale.kr(f)*0.95,1,0,1));

        // grab the frequency of the input signal
        # freq, hasFreq = Tartini.kr(input);

        // map our input signal's frequency to our scale using DegreeToKey
        autotune = (DegreeToKey.kr(scale.as(LocalBuf), freq.cpsmidi, 12) - 55).midicps;

        // use PitchShift to autotune the original signal (adjust windowSize to make it snap quicker, put a Lag on pitchRatio to make it glide, etc.)
	corrected = PitchShift.ar(input, windowSize: 0.1, pitchRatio: (autotune/freq));
	corrected!2;

	    dry = out;
	    out = corrected;
	//out = MantissaMask.ar(Decimator.ar(corrected,44100/4,12),3).tanh;
	    delfreq = 20;
	    out = DelayN.ar(out,1/10-ControlDur.ir,1/delfreq-ControlDur.ir);
	    freqs = (64+[15,16,18]).midicps/8;
	    minfreqs = freqs*0.5;
	    freqs = freqs*MouseButton.kr(1,0.75,4);
	    // 6 comb filters emulate the strings' resonances
	    out = CombN.ar(out!3,1/minfreqs,1/freqs,2).mean.tanh *0.4;
//
	// a little filtering... mouse Y controls amp
	    out = LPF.ar(out,12000);
	    out = HPF.ar(out,50);
	    out = RLPFD.ar(out,8000*[1,1.1],0.1,0.5);
	    out = out + out.mean;
	    out = out * 0.6;
	out = MantissaMask.ar(Decimator.ar(out,44100/4,12),3).tanh;
		out = FaustZitaRev1.ar(
		out,
		out,
		in_delay:100,
		lf_x:4000,
		low_rt60:4,
		mid_rt60:8,
		hf_damping:8000,
		eq1_freq:500,
		eq1_level:2,
		eq2_freq:8000,
		eq2_level:1,
		dry_wet_mix:0.1,
		level:2);

	    2.do {
		d = 0.4.rand;
		  out = AllpassN.ar(out,d,d,5);
	    };


        Out.ar(0,[out, out]);
}
);

s.prepareForRecord;
s.record;
s.stopRecording;