(
// Server config
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
~quadTsBuffers.init("/Users/nunja/Documents/AudioLib/PImpler/timestretch/*");
/*~circularLoopBuffer.init("/Users/nunja/Documents/AudioLib/PImpler/loops/*");
~circularLoopBuffer.get_next({|result|
	result.postln;
});*/
