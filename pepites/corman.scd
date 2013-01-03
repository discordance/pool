fork{
  loop{
    play{
     Splay.ar(
       {Klank.ar(`[99.rand*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(9,1/4,0,0,2)}!2
     )
    };
    1.wait;
  }
};// ‪#endlessRogerCormanmovie‬