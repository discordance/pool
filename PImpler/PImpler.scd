(
// Server config
s.reboot;
s.waitForBoot{
	// Globals
	Library.clear;
	Library.put(\zeroBuffer, Buffer.alloc(s, s.sampleRate, 2));
	/**
	* LOAD THE LIBS
	*/
	(
		"circular.scd".loadRelative;
		"timestretch.scd".loadRelative;
	)
};
)

(
// TESTS
~quadTsBuffers.init("/Users/nunja/Documents/AudioLib/PImpler/timestretch/*",{
	"BIG CALLBACK".postln;
	~quadTsBuffers.cues.postln;
});
)
s.plotTree;
~quadTsBuffers.startSynths;
~quadTsBuffers.cues[\1][\cur];
/*~circularLoopBuffer.init("/Users/nunja/Documents/AudioLib/PImpler/loops/*");
~circularLoopBuffer.get_next({|result|
	result.postln;
});*/

	~quadTsBuffers.cues.postln;
