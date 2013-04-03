/**
 * NUNJA Sample Station v0.1
 * utils.scd
        _
        [ ]
       (   )
        |>|
     __/===\__
    //| o=o |\\
  <]  | o=o |  [>
      \=====/
     / / | \ \
    <_________>

 */

// utility for the sampler
~sampleIndexParse = { |index|
	var arr = [0,0];
	//"sample parse".postln;
	(~buffers[index] != nil).if({arr[0] = ~buffers[index][0].bufnum;});
	(~buffers[index] != nil).if({arr[1] = ~buffers[index][~buffers[index].size - 1].bufnum;});
	arr;
};

// updates kit corrections
~updateCorrections = {
	var num = ~kitCorrectionsBufs.size;
	~kitCorrectionsBufs.keysValuesDo{| key, value |
		value.get(0, {|msg|
			if(msg != 440,{
				~kitCorrectionsArr[key] = ~getCorrection.value(~kitWantedPitch,msg);
			},{
				~kitCorrectionsArr[key] = 1;
			});
			num = num - 1;
			if(num == 0,{
				~kitCorrected = true;
				~set_dr_kit.value(0);
			});
		});
	};
};

// algo to get the good playback rate for correction
~getCorrection = { |midpitch, targetf|
	var tones, base, adist, tone, diff;
	adist = inf;
	tone = 0;
	base = midpitch - 36;
	tones = [];
	7.do({
		tones = tones ++ base.midicps;
		base = base + 12;
	});
	// get the close octave
	tones.do({|el,i|
		if((targetf - el).abs < adist, { adist = (targetf - el).abs; tone =  el; });
	});
	diff = (tone.cpsmidi - targetf.cpsmidi);
	diff = 1/pow(2.0,(diff/12));
};

~drumIndexParse = {|kit, perc|
	var arr = [0,0];
	//~kitBuffers[kit][perc].size.postln;
	(~kitBuffers[kit][perc] != nil).if({
		if(~kitBuffers[kit][perc].size > 0,
		{
			arr[0] = ~kitBuffers[kit][perc][0].bufnum;
		});
	});
	(~kitBuffers[kit][perc] != nil).if({
		if(~kitBuffers[kit][perc].size > 0,{
			arr[1] = ~kitBuffers[kit][perc][~kitBuffers[kit][perc].size - 1].bufnum;
		});
	});
	arr;
};

~set_dr_kit = {|kit|
	~kitCurrent = kit;
	~kitPitches = Object.readArchive(~kitPitchPath++~kitCurrent.floor);
	if(~kitPitches == nil,{
		~kitPitches = Dictionary.new;
		~kitPitches.put(~kitCurrent.floor, [0,0,0,0,0,0,0,0] );
	});
	~dr_synths.do({|synth, i|
		var rate = 1, bounds = ~drumIndexParse.value(~kitCurrent,i);
		if(~kitCorrected == true, {
			rate = ~kitCorrectionsArr[bounds[0]];
		});
		synth.set(\buf_bounds, bounds);
		synth.set(\rate, rate);
	});

};




~ascii =
"
   _____  _    _   _____  _  __
  / ____|| |  | | / ____|| |/ /
 | (___  | |  | || |     | ' /
  \___ \ | |  | || |     |  <
  ____) || |__| || |____ | . \
 |_____/  \____/  \_____||_|\_\

";