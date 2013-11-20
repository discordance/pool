
"/Users/nunja/Documents/AudioLib/supercollider/percussion/hat1/modhh2/modhh2.wav"

"/Users/nunja/Documents/AudioLib/supercollider/percussion/kick/808b/1.wav"
b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/supercollider/percussion/hat1/polyvox/1.wav");
b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/percussion/hat1/dirto/1.wav");
b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/percussion/kick/808b/1.wav");
b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/percussion/hat1/kurzweil/2.wav");

(
x = {
	arg t_trig, buff=1, atk = 0.001, rel = 3, rate = 1;
	var sig, rate_env, env, dur, ienv;
	dur = BufDur.kr(buff);
	ienv = 1-EnvGen.ar(Env.perc(0.1,dur*0.08,0.0001+LFNoise2.kr(50).range(0,0.0001),\sqr),t_trig.lag(0.02),1);
	ienv.poll;
	rate_env = EnvGen.ar(Env.pairs([[0, 1], [0, rate.clip(1,10)], [0.02, rate]], \exp),t_trig);
	env = EnvGen.ar(Env([0.0, 1, 0.98, 0], [atk, rel, 0.1], -4),t_trig);
	sig = PlayBuf.ar(1,buff, BufRateScale.kr(buff)*rate_env, t_trig, 0, 0).lag(1-ienv);
	sig = sig * env;
	Out.ar(0,LeakDC.ar(sig)!2);
}.scope;

d = {


	inf.do{
		x.set(\t_trig,1);
		[0.125,0.25,0.1,0.33].choose.wait;

	}

}.fork;


)

d.stop;

x.set(\t_trig,0.8);
x.set(\rate,0.9);
x.set(\atk,0.001);
x.set(\rel,1);


b;


/****** KICK *******/

x = {
	arg t_trig, buff=0, atk = 0.001, rel = 5, rate = 1;
	var sig, rate_env, env, ienv, dur;
	dur = BufDur.kr(buff);

	ienv = 1-EnvGen.ar(Env.perc(0.1,dur*0.1,0.0025,\sqr),t_trig.lag(0.02),1);
	ienv.poll;
	rate_env = EnvGen.ar(Env.pairs([[0, 1*ienv], [0, rate.clip(1,10)], [0.1, rate]], \exp),t_trig);
	env = EnvGen.ar(Env.adsr(atk,0.1,0.8,rel),t_trig).lag(1-ienv);
	sig = PlayBuf.ar(1,buff, BufRateScale.kr(buff)*rate_env, t_trig, 0, 0).lag(1-ienv);
	sig = sig * env;
	Out.ar(0,LeakDC.ar(sig)!2);
}.scope;




Env.perc(0.1,1,1,\cub).plot;
Env([0.0, 1, 0.9, 0], [0.001, 0.17, 0.01], -4).plot;


Env.new([1, 0.5], [0, 0.1, 1], [1, 1, 1]).plot
o=1;
Env.xyc([[0, 0, \sqr], [0, 0, \sqr], [0.01, 1, \sqr], [3, 0, \cub]]).plot;

Env.perc(1.2,2,1,2).plot;

Env(#[0, 1, 0], #[0, 1], 0, 1).plot;



Env.adsr(0.001,0.3-(0.3*0.05)-0.05,1,0.05).plot;
//.plot;
Env.perc(0.2,0.5,1,\cub).plot;

;
Env.pairs([[0, 0], [0.01, 1], [0.17, 1], [0.17, 0]], \cub).plot;
LADSPA.listPlugins;
LADSPA.ar(1,2588,sig,120,2,0.5,0.5,0.5,440); // delay
LADSPA.ar(1,1795,sig,sig,0.99,1,1,0.8); // plate
LADSPA.ar(1,2589,sig*2,MouseX.kr(0,9),1,1,1); // tonestack
LADSPA.ar(1,2592,2,1,0.5,1,7,1,1,1,0.25,1,1,sig); // amp disto;
LADSPA.ar(1,2598, 1,3,0.3, 1, 0, 0.5, 10,sig,sig); // compressor
{ Blip.ar(Latch.ar(WhiteNoise.ar, Impulse.ar(9)) * 400 + 500, 4, 0.2) }.play;

Env.pairs([[0, 0], [0.01, 1], [0.08, 1], [0.15, 0]], \cub).plot;





(
SynthDef('help-switchdelay-2', { arg out=0, bufnum = 0, delaytime;
    Out.ar(out,
        Pan2.ar(
            SwitchDelay.ar(
                PlayBuf.ar(numChannels: 1, rate: BufRateScale.kr(bufnum)*0.5, bufnum: bufnum, loop: 1) * 0.5,
                wetlevel: 1,
                delaytime:0
            )
        )
    );
}).send(s);
)

x = Synth('help-switchdelay-2', [\bufnum, b, \loop, 0, \delaytime, 2.0]);
x.free;