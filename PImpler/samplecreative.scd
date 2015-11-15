(
b = Buffer.read(s,"/Users/nunja/Music/Madrona Labs/Kaivo/Samples/Nunja/Tracks/diegodeep1.wav",0,-1);
/*b = Buffer.read(s,"/Users/nunja/Documents/AudioLib/exports/DonoussaExports/JazzyRavy/napp0_Divia.wav",0,-1);*/
)

/*c = Scale.partch_o3.ratios;
c = c ++ (Scale.partch_o3.ratios*2);

keep*/

//farahfaza
[1.33484, 2, 2.66986];


(
x = {
	arg rate = 1, out = 0, buffer = 0, bpm = 122;
	var a_snd, a_aph, a_tr, a_env,
	    b_snd, b_aph, b_tr, b_env,
	    mix;
	var pitch = 0;
	var scale = [1, 1.33484, 2, 2.66986];
	scale = scale ++ (scale/2);
	pitch = Select.kr(LFNoise0.kr((bpm/60/4)).range(0, scale.size+1),scale);
	pitch = pitch.lag(0.1);
	pitch.poll;

	a_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
	b_aph = (a_aph+(BufFrames.kr(buffer)/1.33)).wrap(0,BufFrames.kr(buffer));

	a_env = EnvGen.ar(Env.adsr(0.1, 0.3, 1, 0.1), SinOsc.kr((bpm/60/8)));

	a_snd = HPF.ar(BufRd.ar(2, buffer, a_aph*pitch),60);
	a_snd = MoogFF.ar(a_snd, SinOsc.kr((bpm/60/128),0.75).range(300,12000)*a_env, 2.6, 0, 0.5)+(a_snd/1.2);
	a_snd = Pan2.ar(a_snd*a_env, SinOsc.kr((bpm/60), 0.5).range(-0.5,0.5));
	a_snd = Decimator.ar(a_snd,44100, 12);
	// fx
	b_snd = HPF.ar(BufRd.ar(2, buffer, b_aph*(-1)*0.5),100);
	b_snd = PitchShift.ar(b_snd,0.25,pitch,0.01,0.001);
	b_snd = MoogFF.ar(Decimator.ar(b_snd,44100, 13), SinOsc.kr((bpm/60/128),0.5).range(300,12000), 2.6);
	// panning
	b_snd = Pan2.ar( b_snd, SinOsc.kr((bpm/60/16), 0).range(-0.5,0.5));
	b_snd = GVerb.ar(b_snd+(a_snd*0.45), 100, 5, 0.2, 0.6, 50) * 1;

	mix = (b_snd+(a_snd*0.6))/3;


	Out.ar(out, mix);
};
)


x.play();

Scale.directory;

Server.default.makeGui;