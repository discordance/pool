


(
// ----------------
SynthDef(\generator,{
	|
	buffer=0
	|
	var snd = PlayBuf.ar(2,buffer,1,1,0,1);
	Out.ar(15,snd);
}).add;
// -----------

// disto
SynthDef(\fx1, {
	| in, out, amp, dist = 10, centerFreq = 1000, bw = 4, cutoff = 15000, mix = 1 |

	var input, dry, distortion, bandPass, lowPass, sig;

	input = In.ar(in,2);
	dry = input * (1-mix);
	distortion = input * dist;
	distortion = distortion.distort;
	bandPass = BBandPass.ar(distortion, centerFreq, bw);
	lowPass = LPF.ar(bandPass, cutoff);
	sig = lowPass * amp;
	sig = sig * mix;
	sig = sig + dry;
	sig = Out.ar(out, sig);

}).add;

// delay
SynthDef(\fx2, {
	| in, out, maxDelay = 3, delayTime = 2, decayTime = 40, mix = 1, thresh = 0.5
	ratio = 4, attack = 0.01, release = 0.01, amp = 1, inputScale = 0.2 |
	var input, ratioConvert, dry, compressor, delay, limiter, sig, output;
	input = In.ar(in,2);
	dry = input * (1-mix);
	ratioConvert = 1/ratio;
	compressor = Compander.ar(input, input, thresh, 1, ratioConvert, attack, release);
	compressor = compressor * inputScale;
	delay = CombN.ar(compressor, maxDelay, delayTime, decayTime);
	delay = delay * mix;
	sig = (dry + delay) * amp;
	sig = sig.softclip;
	limiter = Compander.ar(sig, sig, 1, 1, 0.1, 0.01, 0.01);
	output = ReplaceOut.ar(out, limiter);
}).add;

// erosion
SynthDef(\fx3, {
	| in, out, freq = 100, rangeLo = 0.002, rangeHi = 0.1, decayTime = 1.5, amp = 0.2, mix = 1 |
	var input, dry, noise, delay, sig;
	input = In.ar(in,2);
	dry = input * (1-mix);
	noise = LFNoise1.ar(freq).range(rangeLo, rangeHi);
	delay = CombN.ar(input, 1, noise, decayTime);
	delay = delay*mix;
	sig = (dry + delay) * amp;
	sig = ReplaceOut.ar(out, sig);
}).add;

// slapdist supernasty
SynthDef(\fx4, {
	|
	in, out, amp = 1, delMix = 0.55, shiftMix = 0.3, verbMix = 0.6,
	maxDelay = 1, delL = 0.1, delR = 0.09,
	int1 = -12, int2 = 7, int3 = 12,
	int1Amp = 0.8, int2Amp = 0.2, int3Amp = 0.6,
	dist = 25, distMix = 0.57, cutoff = 4000
	|

	var input, delayLeft, delayRight, delay;
	var interval1, interval2, interval3, shift1, shift2, shift3, shift;
	var mix, distortion, filter, verb;
	var sig;

	input = In.ar(in,2);
	//input = SoundIn.ar(0);

	delayLeft = DelayC.ar(input, maxDelay, delL);
	delayRight = DelayC.ar(input, maxDelay, delR);
	delay = [delayLeft, delayRight];
	delay = delay * delMix;
	delay = delay + (input * (1-delMix));

	interval1 = exp(0.057762265 * int1);
	interval2 = exp(0.057762265 * int2);
	interval3 = exp(0.057762265 * int3);
	shift1 = PitchShift.ar(input, 0.2, interval1);
	shift1 = shift1 * int1Amp;
	shift2 = PitchShift.ar(input, 0.2, interval2);
	shift2 = shift2 * int2Amp;
	shift3 = PitchShift.ar(input, 0.2, interval3);
	shift3 = shift3 * int3Amp;
	shift = Mix.ar([shift1, shift2, shift3]);
	shift = shift * shiftMix;
	shift = shift + (delay * (1-shiftMix));
	shift = shift ! 2;

	distortion = (shift * dist).distort;
	distortion = distortion * distMix;
	distortion = distortion + ( shift * (1-distMix));
	filter = LPF.ar(distortion, cutoff);

	verb = FreeVerb2.ar(filter[0], filter[1], verbMix, 0.6, 0.8);
	sig = verb * amp;

	sig = Out.ar(out, sig);
}).add;

)


~b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/supercollider/massacre/dumb.wav");
//~c = Buffer.alloc(s,1024,2);
~fx = Synth.new(\fx4,[\in,15,\out,0,\amp,0.2]);
~gen = Synth.new(\generator,[\buffer,~b]);
~fx.set(\amp,0.1,\distMix,1);


s.options.memSize = s.options.memSize * 1000;
s.options.memSize;
