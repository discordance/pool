//y.stop;y.free;y=
fork{
  loop{
    play{
     Splay.ar(
       {Formlet.ar(
          Crackle.ar(2,0.03),
          73.rand.midicps,
          0.0005)
        *EnvGen.kr(Env.perc,1,1,0,9,2)
       }!5)
    };
    9.rand.wait;
   }
};// #sctweet #blueCrackle