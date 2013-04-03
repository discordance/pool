/****
 * MIDI DEBUG
 */



(
MIDIClient.init;
MIDIIn.connectAll;

~pt = 0;

MIDIIn.removeFuncFrom(\sysrt, ~test_clock);
~test_clock = { arg src, val;
	(60.0/(Main.elapsedTime - ~pt)/24).postln;
	~pt = Main.elapsedTime;
};

MIDIIn.addFuncTo(\sysrt, ~test_clock);
)