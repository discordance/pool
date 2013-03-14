/**
 * NUNJA Sample Station v0.1
 * main.scd
        _
        [ ]
       (   )
        |>|
     __/===\__
    //| o=o |\\
  <]  | o=o |  [>
      \=====/
     / / | \ \
    <_________>

 */

// INCLUDES
(
// GLOBAL VARS
"globals.scd".loadRelative;
// UTILS
"utils.scd".loadRelative;
// SYNTH DEFS
"defs.scd".loadRelative;
// ROUTINGS
"routes.scd".loadRelative;
// BUFFERS
"buffers.scd".loadRelative;
// MIDI
"midi.scd".loadRelative;

// INIT PROCESS
{
	"NUNJA SAMPLE STATION".postln;
	"LOAD DEFS".postln;
	~init_defs.value();
	"SYNC".postln;
	s.sync;
	"ROUTING".postln;
	~init_routing_and_clear.value();
	"BUFFERS".postln;
	~init_buffers.value();
	1.wait;
	"CORRECTIONS".postln;
	~updateCorrections.value();
	"MIDI".postln;
	~init_midi.value();

	~ascii.postln;

	"setting ctrl bus defaults .".post;
	3.do({
		".".post;
		1.wait;
	});

	// defaults
	{
		b = Bus.new('control',0,1,s);
		b.setSynchronous(1);
		b = Bus.new('control',1,1,s);
		b.setSynchronous(0);
		b = Bus.new('control',2,1,s);
		b.setSynchronous(0);
		b = Bus.new('control',3,1,s);
		b.setSynchronous(0);
		b = Bus.new('control',4,1,s);
		b.setSynchronous(0);

		8.do({|i|
			b = Bus.new('control',~dr_bus_pitch_base+i,1,s);
			b.setSynchronous(0.5);
		})

	}.value();
	" done.".postln;

}.fork;

)



