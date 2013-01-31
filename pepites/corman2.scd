(
fork{
  loop{
    play{
     Splay.ar(
//       {Klank.ar(`[99.rand*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(9,1/4,0,0,2)}!2
//       {Klank.ar(`[13.rand*(55/4)*(1..8)],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!3
       {Klank.ar(`[12.rand+1*(55/4)*(1..8)],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!3 // no zapguns
//       {Klank.ar(`[((55/2)+(7.rand*2*(55/24)))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!5 // no zap, no static
     )
    };
    1.wait;
  }
};

)

SynthDef(\nun_blue_noise,{
	var sig;]]]]]]]]]]]]]]]]]]]
	 sig = Splay.ar( {Klank.ar(`[12.rand+1*(55/4)*(1..8)],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!4 );
	Out.ar(2,sig);
}).add;

fork{
  loop{
Synth("nun_blue_noise");
	1.wait;
	}
};	