//y.stop;y.free;y=

(
var scale, buffer, freq;

//scale = FloatArray[0, 2, 3.2, 5, 7, 9, 10]; // dorian scale
scale = Scale.phrygian.degrees; //sikah
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });

fork{
  loop{
    play{
	Out.ar(0,
     Pan4.ar(
       {
		  var key;
		  key = DegreeToKey.kr(
				buffer.bufnum,
				LFNoise2.kr(0.003).range(0,15),		// mouse indexes into scale
				12,					// 12 notes per octave
				1,					// mul = 1
				48					// offset by 72 notes
			);

		  Formlet.ar(
						DFM1.ar(Crackle.ar(LFNoise2.kr(0.6).range(1.8,2.0),0.03),SinOsc.kr(0.05).range(800,15000),0.2),
          key.midicps,
          0.0005)

		*EnvGen.ar(Env.perc(LFNoise2.kr(0.3).range(0.01,0.9),LFNoise2.kr(0.9).range(1,20),1,-8),1,1,0,9,2)
			}
					,LFNoise2.kr(0.5),LFNoise2.kr(0.8),0.6));

    };
		[2,8].choose.wait;
   }
};

)

Scale.directory;