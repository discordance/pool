
(
var songs_index = ();
"/Users/nunja/Documents/AudioLib/PImpler/timestretch/*".pathMatch.sort.collect({|file|
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

		// FFT Analysis

	});
});

songs_index.postln;
)


PV_BufRd


