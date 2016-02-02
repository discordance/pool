b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/PImpler/44/akpen_1_3_130-40.wav");

(
SynthDef(\sampler, { arg pos;
var snd, dur;
dur = BufFrames.kr(b) / 8;
snd = BufRd.ar(2, b, Line.ar(pos * dur, (pos + 1) * dur,dur / 48000, doneAction: 2));
Out.ar(0, snd ! 2);
}).add;
)

(
Pbind (\instrument,
\sampler,
\pos,
Prand([0,1,2,3,4,5,6,7], inf), \dur, b.duration / 9).play;
)


{DFM1.ar(Saw.ar((100,100.9..110)).mean,PMOsc.ar(100,300,0.4).exprange(300,9800),0.9).dup * SoundIn.ar(0)}.play


play{f={|o,i|if(i>0,{SinOsc.ar([i,i+1e-4]**2*f.(o,i-1),f.(o,i-1)*1e-4,f.(o,i-1))},o)};f.(60,6)/60};

a=LFTri;play{|f=99|Pan2.ar(a.ar(f+{200.rand+216}.dup(8),{-2pi.rand+2pi}.dup(8),0.01+a.ar({0.01.rand+0.1}.dup(8),0,0.1)),0)}

play{n=Duty;AllpassC.ar(LFTri.ar(n.kr(0.1,0,Dseq([999,99,4000],inf)),0,1)*Dust.kr(n.kr(1,0,Dseq([1,5],inf))),0.2,0.02,1)!2}

play{CombN.ar(SinOscFB.ar(Duty.ar(4,0,Dseq(44+[4,7,2,0],inf)).midicps*[1,1.5],LFNoise0.ar(8!2,1/3,1/2),1/8),1,1/2,9)}

play{GVerb.ar(x=LFNoise0.ar(0.1!2,2.5,3.5);SplayAz.ar(2,LatoocarfianL.ar(SampleRate.ir/2+16.rand,x,x,x,x)!66,x),9+x,9*x)*0.001}