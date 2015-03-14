(
// Server config
s.reboot;
s.waitForBoot{
	/**
	* LOAD THE LIBS
	*/
	(
		"circular.scd".loadRelative;
		"timestretch.scd".loadRelative;
	)
};
)


// TESTS
~quadTsBuffers.init("/Users/nunja/Documents/AudioLib/PImpler/timestretch/*",{
	"BIG CALLBACK".postln;
});
~quadTsBuffers.songs;
/*~circularLoopBuffer.init("/Users/nunja/Documents/AudioLib/PImpler/loops/*");
~circularLoopBuffer.get_next({|result|
	result.postln;
});*/
