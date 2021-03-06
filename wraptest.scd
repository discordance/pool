

(
  Buffer.freeAll;
)

(
var winenv;
// a custom envelope - not a very good one, but you can hear the difference between this
// and the default
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
b = Buffer.read(s, "/Users/nunja/Documents/SuperCollider/Nunja/audiolib/tests/hop.wav");
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\warp, {arg buffer = 0, envbuf = -1;
    var out, pointer, filelength, pitch, env, dir;
    // pointer - move from beginning to end of soundfile over 15 seconds
    pointer = Line.kr(0, 1, 15);
    // control pitch with MouseX
    pitch = MouseX.kr(0.5, 2);
    env = EnvGen.kr(Env([0.001, 1, 1, 0.001], [0.1, 14, 0.9], 'exp'), doneAction: 2);
    out = Warp1.ar(1, buffer, pointer, pitch, 0.1, envbuf, 8, 0.1, 2);
    Out.ar(0, out * env);
}).send(s);

)

// use built-in env
x = Synth(\warp, [\buffer, b, \envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.free;