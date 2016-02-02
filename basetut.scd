(
{
var n;
n=10;

Resonz.ar(
Mix.fill(n,{
var freq, numcps;

freq= rrand(50,560.3);
numcps= rrand(2,20);
Pan2.ar(Gendy3.ar(6.rand,6.rand,1.0.rand,1.0.rand,freq, 1.0.rand, 1.0.rand, numcps, SinOsc.kr(exprand(0.02,0.2), 0, numcps/2, numcps/2), 0.5/(n.sqrt)), 1.0.rand2)
})
,MouseX.kr(100,2000), MouseY.kr(0.01,1.0), 0.3)
;
}.play
)