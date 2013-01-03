s.boot;
p = p ? ProxySpace.push(s);
ProxyMixer.new( p);
(
~metroIn = { arg bpm = 120, shuf = 0.1;
                var sixth, tempo, pulseDur, eighths;
                var upDur = ControlDur.ir * 2;

                tempo = bpm * 15.reciprocal;
                pulseDur = 1/tempo;
                sixth = Duty.ar(
                        pulseDur * Dseq([1+shuf, 1-shuf] *.x [0.5, 0.5], inf),
                        0,
                        Dseq([1, 0], inf)
                );
                eighths =	 PulseDivider.ar(sixth, 2);
                #sixth, eighths = Trig1.ar([sixth, eighths], upDur);
                [ sixth, eighths]
        };
);

~bong = {  Ringz.ar(~metroIn.ar(1,1), 120, 0.5) };	// downbeat
~klong = {  Ringz.ar(~metroIn.ar(1,0), 2000, 0.05) };
~bong.play; ~klong.play; 