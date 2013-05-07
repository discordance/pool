
~change_rate = false;
~init_midi.value();
~fxEq.set(\mix,1);

~fxEq.set(\hi,1);
~fxEq.set(\lo,5);


~get_os_buffers.value(60);
~splr_params.rate = 0.5;
~splr_params.density = 0;
~splr_params.bias = 0.2;

~set_dr_kit.value(1);
~kit_params.density = 1;

~pad_counter.pad_a = 2;
~pad_counter.pad_b = 2;


~scale = ~scale /2;
b = Bus.new('control',7,1,s);
b.set(0.9);
b.set(0.8);


(

~create_octave_down_ratios = {|scale|
	var arr = [];
	scale.do({|elem, i|
		arr = arr.add([0.5,1].asSpec.map(elem-1));
	});
	arr;
};

~scale =  Scale.zamzam.ratios.resamp0(4);
~scale = ~scale ++ ~create_octave_down_ratios.value(~scale);

)
Scale.directory;



x = {
	var test;
	test = SinOsc.kr(0.01).range(0.3,0.4);
	Out.kr(6,test);
	Out.kr(7,test);
}

x.play;
x.free;


MIDIClient.init;

DrumTrack


