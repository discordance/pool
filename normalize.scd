/**
 * SOX Normalize OS
 */
(
~osPath = "/Users/nunja/Documents/SuperCollider/Nunja/audiolib/os/*";
~pathArr = ~osPath.pathMatch.sort.collect{|file|
	file.insert(file.size,"*");
};

~pathArr.do{ |folder, i|
	folder.pathMatch.sort.collect{|file, i|
		//file.postln;
		("sox --norm"+file+file.insert(file.size-5,"norm")).postln;
		"sleep 1".postln;
	};
};
)