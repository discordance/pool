(
var midifile = MIDIFile.new;
midifile.read("/Users/nunja/Documents/Lab/MIDI/Toontrack Monster Midi Pack 1, 2 & 3/Pack 1/Monster_MIDI_Pack_WIN/Drag me into EZplayer/000090@MONSTER_MIDI_PACK/106@SWING_4#4/093-S012@HATS_CLOSED_VARIATIONS/Variation_02.mid");
//(midifile.division).postln;
midifile.scores.at(0).do({|event|
	event.at(0).postln;
});
)


(983/9600)*96;

480*4;