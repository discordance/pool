/*
Waveshaper

References : Posted by Partice Tarrabia and Bram de Jong

Notes :
amount should be in [-1..1[ Plot it and stand back in astonishment! ;)

Code :
x = input in [-1..1]
y = output
k = 2*amount/(1-amount);

f(x) = (1+k)*x/(1+k*abs(x))
http://www.musicdsp.org/archive.php?classid=4#203
*/

(
{
	var x = SinOsc.ar(220, 0, 0.8);
	var amount = MouseX.kr(-1, 1);
	var k = 2 * amount / (1 - amount);
	(1 + k) * x / (1 + (k * x.abs)) ! 2;
}.scope

)

//a bit of filtering and tweaking, you get a decent guitar amp...

(
{
	var in, amount, amCoef;
	in = HPF.ar(SinOsc.ar(220, 0, 0.8), 400)*5;
	amount = 0.99;
	amCoef= 2*amount/(1-amount);
	MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
}.play;
)

SynthDef(\tanhDistortion,
{
    arg in = 0, out = 0, distortGain = 1;

    var signal = In.ar(in, 2) * distortGain; // Input Signal (inBus)
    var distortedOutput = tanh(signal);

    Out.ar(out, distortedOutput); // Output Signal (outBus)
}).add;



SynthDef("nun_nasty", {|in = 0, out = 0, drv = 0, amp = 1,jitf = 0.1, jit = 0.1,env = 0,
			lag = 1, lpp = 120, res = 0.1, gate = 1, att = 0.001, rel = 0.1|
			var sig, x3, jitter, input, envf;
			input = In.ar(in, 2);
			drv = Lag.kr(drv, lag).dbamp;
			sig = drv * Clipper8.ar(input, -1.875,1.875);
			envf = AmplitudeMod.ar(input,att, rel);
			jitter =  (envf * jit)+1;
			x3 = sig.pow(3);
			sig = ((x3 *(-0.18963)) + sig) + (x3*sig.pow(2) * 0.0161817*jitter);
			sig = SoftClipper8.ar(sig);
			sig = XFade2.ar(sig, sig*envf, (env * 2)-1);
			sig = LeakDC.ar(sig);
			sig = BMoog.ar(sig, Lag.kr(lpp, lag).midicps, res, 0);
			sig = sig * EnvGen.kr(Env.asr(lag, 1, lag), gate, doneAction:2);
			Out.ar(out, sig * Lag.kr(amp, 1));
}).add;
