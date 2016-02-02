(
/*
* Manages Four buffers, FFT Analysis for real time timestretch
* Manage preloading next and previous buffers on selection of a buffer
* This buffer manager isnt circular
*/
~quadTsBuffers = (
	// ### props
	// root path
	\root: nil,
	// fft related
	\fftWindow: 2048,
	\fftHop: 0.25,
	// is loading
	\loading: false,
	// current song selection
	\current_song: 0,
	// current part selection
	\current_part: 0,
	// songs contain all the logic of song, the four tracks buffers timestretchable
	\songs: nil,
	// currently available buffers
	\cues: (
		\1: (\pre:nil, \cur:nil, \nex:nil),
		\2: (\pre:nil, \cur:nil, \nex:nil)
	),
	\trackOne:nil,
	\trackTwo:nil,
	\startSynths: {|o, done|
		// synthdef
		s.bind {
			SynthDef("pvplay", { arg out=0, recBuf=1, winSize=1024, rate = 1;
				var in, chain, bufnum, l;
				bufnum = LocalBuf.new(winSize, 1);
				chain = PV_PlayBuf(bufnum, recBuf, rate, 0, 1);
				//BufDur.kr(recBuf).poll;
				l = IFFT(chain, 1);
				// PSEUDO STEREO
				// PV_Diffuser ????
				Out.ar(out, Pan2.ar(l.dup,0));
			}).send(s);

			s.sync;

			(o.trackOne != nil).if({ o.trackOne.free; });
			(o.trackTwo != nil).if({ o.trackTwo.free; });
			//o.trackOne = Synth("pvplay", [\out, 0, \recBuf, o.cues[\1][\cur], \winSize, o.fftWindow ]);
			o.trackTwo = Synth("pvplay", [\out, 0, \recBuf, o.cues[\2][\cur], \winSize, o.fftWindow ]);
		};
	},
	\setSpeed: {|o, speed|
		o.trackOne.set(\rate, speed);
		o.trackTwo.set(\rate, speed);
	},
	// takes a callback, done
	\init: {|o, root, done|
		// create the songs
		// parse files
		var songs_index = ();
		o.rootPath = root;
		root.pathMatch.sort.collect({|file|
			var path = PathName.new(file);

			if(path.folderName != "analysis", {
				var splitted = path.fileName.split($_);
				var song_name = splitted.at(0).asSymbol;
				var track_num = splitted.at(1).asSymbol;
				var part_num = splitted.at(2).asSymbol;
				var tempo = splitted.at(3);
				var tempo_int, tempo_dec;

				// create the song datastructure
				(songs_index[song_name] == nil).if({
					songs_index[song_name] = (\tracks:());
				});
				(songs_index[song_name][\tracks][track_num] == nil).if({
					songs_index[song_name][\tracks][track_num] = ();
				});
				(songs_index[song_name][\tracks][track_num][part_num] == nil).if({
					songs_index[song_name][\tracks][track_num][part_num] = file;
				});
				// find out tempo
				tempo_int = tempo.split($.).at(0).split($-).at(0);
				tempo_dec = tempo.split($.).at(0).split($-).at(1);
				// reuse
				tempo = tempo_int;
				(tempo_dec != nil).if({ tempo = tempo ++ "." ++ tempo_dec });
				songs_index[song_name][\bpm] = tempo.asFloat;
				// set songs
				o.songs = songs_index;
			});
		});
		o.analysis(root, o.songs, {
			o.initBuffers(o.songs, done);
		});
	},
	\initBuffers: {|o, songs, done|
		//Library.at(\zeroBuffer).postln;
		var song = o.songs.asArray[o.current_song];
		// init to zero buff
		var b1,b2, loaded = 0, toload = 0;
		var assign = {
			// cur
			o.cues[\1][\cur] = b1;
			o.cues[\2][\cur] = b2;
			// prev
			o.cues[\1][\pre] = Library.at(\zeroBuffer);
			o.cues[\2][\pre] = Library.at(\zeroBuffer);
			// next
			o.cues[\1][\nex] = Library.at(\zeroBuffer);
			o.cues[\2][\nex] = Library.at(\zeroBuffer);
		};
		b1 = Library.at(\zeroBuffer);
		b2 = Library.at(\zeroBuffer);
		(song != nil).if({
			(song.tracks[\1] != nil).if({
				// select part
				(song.tracks[\1].asArray[o.current_part] != nil).if({
					toload = toload+1;
					b1 = Buffer.read(s, song.tracks[\1].asArray[o.current_part], 0, -1, {|b|
						b.postln;
						loaded = loaded+1;
						(loaded == toload).if({
							assign.value();
							done.value();
						});
					});
				});
			});
			(song.tracks[\2] != nil).if({
				// select part
				(song.tracks[\2].asArray[o.current_part] != nil).if({
					toload = toload+1;
					b2 = Buffer.read(s, song.tracks[\2].asArray[o.current_part], 0, -1, {|b|
						b.postln;
						loaded = loaded+1;
						(loaded == toload).if({
							assign.value();
							done.value();
						});
					});
				});
			});
		});
	},
	\analysis: {|o, rootPath, songs, done|
		var totalProcessed = 0;
		var getAnafilePath = {|root,file|
			var path = PathName.new(root);
			var anafile = path.pathOnly;
			anafile = anafile ++ "analysis/" ++ PathName.new(file).fileNameWithoutExtension;
			anafile = anafile ++ ".scpv";
		};
		var countFiles = {
			var ct = 0;
			songs.keysValuesDo{|song_key, song|
				song.tracks.keysValuesDo{|track_key, track|
					track.keysValuesDo{|file_key, file|
						ct = ct + 1;
					};
				};
			};
			ct;
		};
		var counterFunc = {
			var totalfiles =countFiles.value();
			totalProcessed = totalProcessed+1;
			(totalProcessed.asString++" on "++totalfiles.asString++" processed ...").postln;
			if(totalProcessed == totalfiles,{
				"DONE".postln;
				done.value();
			});
		};

		s.bind {
			// load analysis synthdef
			SynthDef("pvrec", { arg recBuf=1, soundBufnum=2, dur = 4.0, winSize=1024, hop=0.5;
				var in, chain, bufnum;
				bufnum = LocalBuf.new(winSize);
				Line.ar(1, 1, dur, doneAction: 2);
				in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 1);
				// note the window type and overlaps... this is important for resynth parameters
				chain = FFT(bufnum, in, hop, 1);
				chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, hop, 1);
			}).send(s);
			// loaded
			s.sync;
			// perform the analysis
			songs.keysValuesDo{|song_key, song|
				var calcAcute = (((((60000.0*16.0*96000.0)/song.bpm)/1000.0)*100.0)/100.0)*4;
				song.tracks.keysValuesDo{|track_key, track|
					track.keysValuesDo{|file_key, file|
						var sf, analysis_buf;
						var fourBarDur = ((calcAcute/96000)/16)*4;
						// check if analysis file is here already
						if( File.exists(getAnafilePath.value(rootPath, file)) == true , {
							track[file_key] = getAnafilePath.value(rootPath, file);
							counterFunc.value();
							},{
								//
								// here the file
								// get some info about the file
								sf = SoundFile.new(file);
								sf.openRead;
								sf.close;

								analysis_buf = Buffer.alloc(
									s,
									calcAcute,
									1,
									// completion fonction
									{
										var audio_buf = Buffer.read(s, file, 0, -1, {|buf|
											var recSynth = Synth("pvrec", [
												\recBuf, analysis_buf,
												\soundBufnum, audio_buf,
												\winSize, o.fftWindow,
												\hop, o.fftHop,
												\dur, fourBarDur
											]);

											recSynth.onFree({
												var anafile = getAnafilePath.value(rootPath, file);
												var ctFunc = counterFunc;
												var routfork = {
													0.25.wait;
													analysis_buf.free();
													audio_buf.free();
													track[file_key] = anafile;
													ctFunc.value();
												};

												analysis_buf.write(anafile, "wav", "float32",-1,0,false,{
													routfork.fork;
												});
												//
												"ok";
											});
										});
									}
								);
						});
					}
				};
			};
		}
	}
);
)

