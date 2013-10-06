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

BOOTSTRAP CLASSES
******************************************************************/
(
~oMODULE = CLASS.new;
~oMODULE.id = ""; // module id
~oMODULE.router = (know:false); // router reference
~oMODULE.root_path = "";
~oMODULE.kr_route_map = (); // route of control busses
~oMODULE.ar_route_map = (); // route of audio busses
~oMODULE.func_route_map = (); // route of functions
~oMODULE.load_synthdefs = {};
~oMODULE.on_ready = {};
~oMODULE.on_note = {};
~oMODULE.on_clock = {};
~oMODULE.ready = false;
~oMODULE.get_preset = {};
~oMODULE.set_preset = {};


// FX is quite a module after all ;
~oFX = ~oMODULE <
(
\in_bus: 0,
\out_bus: 0,
\chain_bus: 0
)

)
