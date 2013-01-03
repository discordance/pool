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
