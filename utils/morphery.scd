

(
// MONO
/*
~mode = 1;

SynthDef(\pvmorph, { arg out=0, b1=0, b2=1, b3=2, longest=0, outbuf=10, r0, r1, r2;
	var in1, chain1, in2, chain2, in3, chain3, chain, env, res;
	in1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1)*r0, loop: 0);
	in2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2)*r1, loop: 0);
	in3 = PlayBuf.ar(1, b3, BufRateScale.kr(b3)*r2, loop: 0);
	env = PlayBuf.ar(1, longest, BufRateScale.kr(longest)*r0, loop: 0, doneAction:2);
	chain1 = FFT(LocalBuf(2048), in1);
	chain2 = FFT(LocalBuf(2048), in2);
	chain3 = FFT(LocalBuf(2048), in3);
	chain = PV_XFade(chain1, chain2, 0.5);
	chain = PV_XFade(chain, chain3, 0.5);
	chain = PV_Morph(chain, chain1, Rand(0,1));
	chain = PV_Morph(chain, chain2, Rand(0,1));
	chain = PV_Morph(chain, chain3, Rand(0,1));
	res = IFFT(chain);
	DiskOut.ar(outbuf,res);
	Out.ar(out, res);
}).add;
*/

// STEREO

~mode = 2;
SynthDef(\pvmorph, { arg out=0, b1=0, b2=1, b3=2, longest=0, outbuf=10, r0, r1, r2;
	var in1, chain1, in2, chain2, in3, chain3, chain, env, res;
	in1 = PlayBuf.ar(2, b1, BufRateScale.kr(b1)*r0, loop: 0);
	in2 = PlayBuf.ar(2, b2, BufRateScale.kr(b2)*r1, loop: 0);
	in3 = PlayBuf.ar(2, b3, BufRateScale.kr(b3)*r2, loop: 0);
	env = PlayBuf.ar(2, longest, BufRateScale.kr(longest)*r0, loop: 0, doneAction:2);
	chain1 = FFT(LocalBuf(8192), in1);
	chain2 = FFT(LocalBuf(8192), in2);
	chain3 = FFT(LocalBuf(8192), in3);
	chain = PV_XFade(chain1, chain2, 0.5);
	chain = PV_XFade(chain, chain3, 0.5);
	chain = PV_Morph(chain, chain1, Rand(0,1));
	chain = PV_Morph(chain, chain2, Rand(0,1));
	chain = PV_Morph(chain, chain3, Rand(0,1));
	res = IFFT(chain);
	DiskOut.ar(outbuf,res);
	Out.ar(out, res);
}).add;

//

//~dir = "/Users/nunja/Documents/AudioLib/supercollider/percussion/";
//~target = "/Users/nunja/Documents/AudioLib/supercollider/morph/";

//~dir = "/Users/nunja/Documents/AudioLib/supercollider/morph/";
//~target = "/Users/nunja/Documents/AudioLib/supercollider/morph2/";

//~dir = "/Users/nunja/Documents/AudioLib/supercollider/morph2/";
//~target = "/Users/nunja/Documents/AudioLib/supercollider/morph3/";


~dir = "/Users/nunja/Documents/AudioLib/supercollider/os/";
~target = "/Users/nunja/Documents/AudioLib/supercollider/morphod/";

//~dir = "/Users/nunja/Documents/AudioLib/supercollider/morpho/";
//~target = "/Users/nunja/Documents/AudioLib/supercollider/morpho2/";

~list = [];
~triplets = [];
~parse_dir = {|dir|
	if(File.type(dir) != \directory,{
		~list = ~list.add(dir);
	},{
		dir = dir ++ "*";
			dir.pathMatch.sort.collect{|file|
				~parse_dir.value(file);
			}
	});
};
~parse_dir.value(~dir);
~list = ~list.scramble;
~triple = [];
~list.do{|el,i|
	~triple = ~triple.add(el);
	if(~triple.size == 3,{
		~triplets = ~triplets.add(~triple);
		~triple = [];
	});
};
~processed = 0;
// func
~process_next = {|triple|
	var bufs = [] ;

	var play = {
		var synth, wrapper, max = bufs[0], outbuf, rs;
		bufs.do{|el,i|
			if(el.numFrames > max.numFrames,{
				max = el;
			});
		};
		s.recChannels = ~mode;
		s.prepareForRecord(~target ++ "morf" ++ ~processed.asString ++ ".aiff");
		// R
		rs = Array.fill(3, {
			rrand(0.6,1.4);
		});
		rs = rs.sort;


		synth = Synth.new(\pvmorph, [
			\b1,bufs[0],
			\b2,bufs[1],
			\b3,bufs[2],
			\longest,max,
			\r0,rs[0],
			\r1,rs[1],
			\r2,rs[2]
		]).register;
		synth.addDependant { |node, msg|
			if(msg == \n_go,{
				s.record;
			});
			if(msg == \n_end,{
				if(~triplets.size > 0,{
					s.stopRecording;
					~processed = ~processed + 1;
					~process_next.value(~triplets.removeAt(0));
					},{
						"finished".postln;
						s.stopRecording;
				});

			});
		};

	};

	triple.do{|file|
		Buffer.read(s, file, action: {|buf|
			bufs = bufs.add(buf);
			if(bufs.size == 3, {
				play.value();
			});
		});
	};
};

~process_next.value(~triplets.removeAt(0));
)



