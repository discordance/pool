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
	var arr = [0,0], pre, suff;
	pre = (index/4).floor;
	suff = index % 4;
	if(~osBuffers[pre][suff] != nil, {
		var preset_name = ~osBuffers[pre][suff][0].path.dirname.basename.toUpper;
		arr[0] = ~osBuffers[pre][suff][0].bufnum;
		arr[1] = ~osBuffers[pre][suff][~osBuffers[pre][suff].size-1].bufnum;
		"PAD : ".post; preset_name.postln;
	},{
		"PAD : EMPTY !".postln;
	});
	arr;
};

// updates kit corrections
/*
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
*/
// algo to get the good playback rate for correction
/*
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
*/
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

~get_os_buffers = {|midival|
	var b = 0, tabz = [], bank_a, bank_b;
	~sampleIndex = [0,~sampleSetsTotal-1, \lin, 2].asSpec.map(midival/128).floor;
	b = ~sampleIndex+1;
	if((~sampleSetsTotal/2) % (~sampleSetsTotal/2).floor != 0,{
		b = ~sampleIndex;
	});


	~buffers.do({|el,i|
		if(i == ~sampleIndex,{
			bank_a = ~buffers.findKeyForValue(el).toUpper;
			tabz = tabz.add([]);

			el.do({|ell,ii|
				tabz[0] = tabz[0].add(ell);
				//ii.postln;
			});
		});
		if(i == b,{
			bank_b = ~buffers.findKeyForValue(el).toUpper;
			tabz = tabz.add([]);
			el.do({|ell,ii|
				tabz[1] = tabz[1].add(ell);
			});
		});
	});
	~osBuffers = tabz;
	"Loaded OS Banks: ".postln;
	bank_b.postln;
	bank_a.postln;
	"";
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

~prepareEQ =
{   arg storage, eqtype;
	var path, convFFTsize;

	convFFTsize = 4096;
	path = ~userPath ++ "AudioLib/supercollider/impulses/"++eqtype++"/";

	storage.nb = Buffer.read(s, path ++ "main.wav");

	s.sync;
};


/**
 * MELODIC STUFF AND TIMED MODIFIERS
 *
 *
 */
~new_tick = {|tick|

};
~new_pad = {|pad_num|

	if(~change_rate == true, {
		~splr_params.rate = ~scale.choose;
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