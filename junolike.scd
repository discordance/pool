// modularity-in-virtual-analog-synth-design-with-supercollider.rtf


// i'm splitting up a few pieces into inline functions (osc_pitch_from, vco, vcf)
// mainly for legibility and ease of modification

// synthesis is modelled a bit after mda jx10 and juno 106

(
SynthDef(\jx10, {

        arg freq=440,
        detune=0.6,
        vco1_tune=0,
        vco2_tune=(-24),
        noise=0,
        sub=0.1,
        vca_release=5,
        vcf_cutoff=4200,
        vcf_res=0.2,
        vcf_grit=0;

        var sig, vco1, vco2, vco3, nois, vca1;

        var osc_pitch_from = { |freq, tune, detune|
                (freq.cpsmidi + tune).midicps - detune;
        };

        var vco = { |freq|
                Saw.ar(freq);
        };

        var vcf = { | in, dist=0 |
                MoogFF.ar(in, vcf_cutoff + WhiteNoise.kr(mul:vcf_grit*100), vcf_res) * 2;
        };

        vco1 = vco.(osc_pitch_from.(freq, vco1_tune, detune));
        vco2 = vco.(osc_pitch_from.(freq, vco2_tune, detune));
        vco3 = Pulse.ar(freq/4, 0.5) * sub;
        nois = PinkNoise.ar * noise;
        vca1 = Env.perc(releaseTime:vca_release).ar(doneAction:2);

        sig = vcf.(vco1 + vco2 + vco3 + nois * vca1) / 2;

        Out.ar(0, sig ! 2);

}).add;
)

// a few notes at a time
(
Pbind(
        \instrument, \jx10,
        \freq, Pseq([500, 600, Prand([200, 456, 345],1)], inf),
        \legato, Pseq([1.5, 0.2], inf),
        \dur, 0.4,
        \out, Pseq([0, 1], inf),
        \detune, Prand([0.1, 0.6, 2], inf),

        \noise, Pwhite(0, 1, inf),

        \vcf_cutoff, Pwhite(400, 4400, inf),
        \vcf_res, Pwhite(0.5, 0.6, inf),
        \vcf_grit, Pwhite(0, 1, inf)

).play;
)

// or, try this arpeggiation-eque pattern (two options for release, comment the one you don't need)
(
Pbind(
        \instrument, \jx10,

        \scale, Scale.phrygian,

        \root, 7,

        \degree, Pseq([
                Pshuf(#[-7,-3,0,2,4,7], 4)+[0,3,12],
                Pseq( [-12,12,2,3,5,7,12] )+[0,7,12],

                Pshuf(#[-7,-3,0,2,4,7], 4)+[0,2,3],
                Pseq( [-12,12,2,3,5,7,12] )+[0,7,-12]
        ], inf),

        \legato, Pseq([1.5, 0.2], inf),
        \dur, 1/4,

        \detune, Prand([0.1, 0.6, 2], inf),

        \noise, Pwhite(0, 1.0, inf),

        /*\vca_release, Pwhite(0.3, 0.7, inf),*/
        \vca_release, Pgbrown(0.12, 3, inf),

        \vcf_cutoff, Pwhite(200.0, 3400.0, inf),
        \vcf_res, Pwhite(0.5, 0.6, inf),
        \vcf_grit, Pwhite(0, 2.0, inf)

).play;
)