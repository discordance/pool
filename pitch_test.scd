b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/drumkit/0/3/1.wav");

c = Buffer.alloc(s, b.numFrames / s.options.blockSize);



{
	var sig = PlayBuf.ar(1, b, 1, doneAction:2,loop:0);
	//RecordBuf.kr(Tartini.kr(PlayBuf.ar(1, b, doneAction:2, loop:0)).at(0), c)
	Tartini.kr(sig).poll;
	sig;
}.play;

c.get(0, {|msg| msg.postln});


(
{
	arg midpitch, targetf;
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

}.value(48,100);
)

(
1/pow(2.0,(1.17/12));
)

523.2511306012.cpsmidi;

140.cpsmidi
/*
expr $f2/pow(2.,($f1/12.))
f1=semitone
f2=original length
*/
