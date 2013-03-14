
(
var scale, buffer;
scale = [0,5,1,-2,-7];//Scale.dorian.degrees; //sikah
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });

{
	var arr, modArr, out, noises;
	var key1, key2, key3, rate;
	var s, z, y;

	rate = 4;

	key1 = DegreeToKey.kr(
				buffer.bufnum,
				LFNoise2.kr(0.008*rate).range(0,15),		// mouse indexes into scale
				3,					// 12 notes per octave
				2,					// mul = 1
				56					// offset by 72 notes
			);

	key2 = DegreeToKey.kr(
				buffer.bufnum,
				LFNoise2.kr(0.02*rate).range(0,15),		// mouse indexes into scale
				2,					// 12 notes per octave
				2,					// mul = 1
				68					// offset by 72 notes
			);

	key3 = DegreeToKey.kr(
				buffer.bufnum,
				LFNoise2.kr(0.02*rate).range(0,15),		// mouse indexes into scale
				3,					// 12 notes per octave
				2,					// mul = 1
				56					// offset by 72 notes
			);

	arr = ([key1.midicps, key2.midicps, key3.midicps]*0.33*LFNoise2.kr(0.02*rate).range(0.99,1.01)) ++ ([key1.midicps, key2.midicps, key3.midicps]*LFNoise2.kr(0.02*rate).range(0.999,1.01)) ++ ([key1.midicps, key2.midicps, key3.midicps] *1.33*LFNoise2.kr(0.02*rate).range(0.98,1.03));

	modArr = {LFNoise2.kr(rrand(0.03,0.9)).range(0.1,0.9)}.dup(9);
	noises = Formlet.ar(WhiteNoise.ar(),[key1.midicps,key2.midicps,key3.midicps]*2,2)*0.01;
	out = Blip.ar(arr,0,modArr)+noises*0.2;
	out = RLPF.ar(out, SinOsc.kr(0.001*rate).range(1000,20000)).distort;
	out = RLPF.ar(out, SinOsc.kr(0.06*rate).range(700,20000)).distort;
	out = out.tanh.tanh;
	z = DelayN.ar(out, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 4) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	out = out+(y*0.1).tanh;
	out = out*0.2 ! 2;
	Out.ar(0,out);
}.play
)


Scale.directory;




Scale.dorian.degrees;


