/*****************************************************************

                        boing         boing         boing
              e-e           . - .         . - .         . - .
             (\_/)\       '       `.   ,'       `.   ,'       .
              `-'\ `--.___,         . .           . .          .
                 '\( ,_.-'
                    \\               "             "            "
                    ^'
SPLR v2 - Vauban
****

MAIN
******************************************************************/
(
s.waitForBoot({
	/**
	* LOAD CLASSES
	*/
	// load bootstrap for class inheritance;
	"_bootstrap.scd".loadRelative;
	// modules
	"Router.scd".loadRelative;
	"Drums.scd".loadRelative;
	/**
	* INIT AND LOAD
	*/
	// ROUTER FIRST
	~oROUTER.init();
	// DRUMS
	~oDRUMS.init("/Users/nunja/Documents/AudioLib/supercollider/percussion/");
	~oDRUMS.load();
	~oROUTER.assign(~oDRUMS);

});
)

