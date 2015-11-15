

(
t= TempoClock.new;
t.schedAbs(t.beats.ceil/4, { arg beat, sec; [beat, sec].postln; t.nextBar.postln; 0.25 });
t.tempo_(2.0);
)

(\a:2,\b:435,\c:"LOL").writeArchive("/Users/nunja/test.arch");


d = DOMDocument.new("/Users/nunja/dumm.xml");