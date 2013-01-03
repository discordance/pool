

(
// define a simple reverb.
SynthDef("reverb", {
	var in;
	in = In.ar(0, 2);
	5.do({ in = AllpassN.ar(in, 0.05, [0.05.rand, 0.05.rand], 2); });
	ReplaceOut.ar(0, in);
}).add;
)

(

var scale, buffer;
scale = FloatArray[0, 2, 3.2, 5, 7, 9, 10]; // dorian scale
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });

{

var n, in, distortion, fx;

n=30;

in = MoogFF.ar(
Mix.fill(n,{
var freq, numcps;

			freq = ([450,320,390]*3).choose;//390, 460

numcps= rrand(15,25);
			Pan2.ar( LFSaw.ar(freq,0,0.01) +

				Gendy1.ar(6.rand,6.rand,LFCub.ar(0.01,0.8,1,0.1).abs,LFCub.ar(0.01,0.8,1,0.1).abs, freq ,freq, LFCub.ar(0.01,0.2,1,0.1).abs, LFCub.ar(0.1,0.8,1,0.1).abs, numcps, SinOsc.kr(exprand(0.02,0.2), 0, numcps/2, numcps/2), 0.5/(n.sqrt)), 1.0.rand2)
})
,MouseX.kr(100,8000), 0.1) * MouseX.kr(0.0,0.5);

	fx = 0;
	distortion = (in * 2).distort * (2.distort * LFCub.ar(0.01,0,0.1,0.0).abs);
	fx = Compander.ar(distortion, distortion, 0.8, 1.2, 1 ); // sustain
	in = (LeakDC.ar( (fx + in) ) * 0.8).scaleneg(0.5) * LFCub.ar(0.01,0,1,0.5).abs;
	Out.ar(2,in);
}.play


)
