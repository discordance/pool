/**
 * NUNJA Sample Station v0.1
 * routes.scd
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

~init_routing_and_clear =
{
	// clear clear !!
	Server.all.do(_.freeAll);

	// buffers
	// BUFFER INIT --------------------------------
	Buffer.freeAll; // free all buffers
	// create the emptybuffer zero, the void buffer
	~voidBuffer = Buffer.alloc(s, 0.5 * s.sampleRate, 2);

	// buffers for waveshaping
	~chebBuffer = Buffer.alloc(s,1000,1,0);
	~chebBuffer.sendCollection(Signal.sineFill(1000, [1, 1.0.rand, 1.0.rand, 1.0.rand]), 0);

	// ROUTE
	~splr_source = Group.head(s);
	~splr_drums = Group.head(s);
	~splr_premix = Group.tail(s);
	~splr_fx = Group.tail(s);


	~os_mixer = Synth.head(~splr_premix, "nun_pre_mixer");
	~os_mixer.set(\in, ~osBus, \out, ~compBus, \fx, ~fxBusses, \ctbase, 2);

	~drum_mixer = Synth.head(~splr_premix, "nun_pre_mixer");
	~drum_mixer.set(\in, ~drumBus, \out, ~compBus, \fx, ~fxBusses, \ctbase, 9);

	~fx_echo = Synth.head(~splr_fx, "nun_dubecho");
	~fx_echo.set(\in, ~fxBusses, \out, ~compBus);

	~fx_reverb = Synth.head(~splr_fx, "nun_reverb_a");
	~fx_reverb.set(\in, ~fxBusses+2,\out, ~compBus);

	~fx_nasty = Synth.head(~splr_fx, "nun_nasty");
	~fx_nasty.set(\in, ~fxBusses+4,\out, ~compBus, \buff, ~chebBuffer);

	~fx_comp = Synth.tail(~splr_fx, "nun_leveler");
	~fx_comp.set(\in, ~compBus, \thresh, -12, \out, ~mainOut, \amp, ~mainVol);

}