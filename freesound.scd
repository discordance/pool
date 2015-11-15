// roasted:
// kick until page 4
// perc until page 1


// new DISCO
(
Freesound.clientId="b8b1b0126cbd3af6118f";
Freesound.clientSecret = "e907a5b8ab90bf891298a8474b203bd1f424d679";
Freesound.authType = "oauth2";
Freesound.getAuthorizationPage;
)
(
Freesound.getToken("2276caa3ecaa0ae9a56a34b0b78fd342f9b3c594");
)



// new VAUBAN
(
Freesound.clientId="26e34c97d0ab6efe48fa";
Freesound.clientSecret = "8d4bd8d36402fb949dd0bf9ad2db7345d5cfffab";
Freesound.authType = "oauth2";
Freesound.getAuthorizationPage;
)
(
Freesound.getToken("522c9122d81a421efcf7f27e1fcfe84d393daff9");
)


// refresh
/*(
Freesound.clientId="b8b1b0126cbd3af6118f";
Freesound.clientSecret = "e907a5b8ab90bf891298a8474b203bd1f424d679";
Freesound.authType = "oauth2";
Freesound.refreshToken;
)*/

(
FSSound.textSearch( query: "oriental+voice", filter: "type:wav duration:[4 TO 10]", params:('page_size':150,'page':2), action:{|p|

	//var base = "/Users/nunja/Documents/AudioLib/freesound/kick/";
	var base = "/Users/nunja/Documents/AudioLib/freesound/vocals/";

	var routine = {|item|
		p.do({|item|
			item.name.postln;
			item.getAnalysis( "tonal.key_key", {|val|
				var key = val.tonal.key_key;
				var path = base ++ key ++ "_" ++ item.name.toLower.replace(" ","").replace(".wav","") ++ ".wav";
				var mvcmd = "mv /tmp/" ++ item.name.escapeChar($ ) ++ " " ++ path;

				item.retrieve("/tmp/", {
					mvcmd.unixCmd;
					(path ++ " done!").postln;
				});
			});
			5.wait;
		});
	};
	routine.fork;
});
)


~snd.retrieve("/tmp/", {
	~buf = Buffer.read(s, "/tmp/" ++ ~snd.name);
	("/tmp/" ++ ~snd.name).postln;
	"done!".postln;
});

~buf.play;

~snd.getSimilar( action:{|p| ~snd = p[1] ;});
~snd["name"].postln;

~snd.retrieve("/tmp/", {
	~buf = Buffer.read(s, "/tmp/" ++ ~snd.name);
	("/tmp/" ++ ~snd.name).postln;
	"done!".postln;
});



{
	1000.do{
		1.wait;
		"pos".postln;
	};
}.fork;