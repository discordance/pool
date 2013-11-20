
(
MIDIClient.init;
~mout = MIDIOut.newByName("Elektron Analog Four", "Elektron Analog Four");
)

(
~exept = [ [[1,5],8],
	  [[1,6],5],
	  [[1,25],8],
	  [[1,26],5],
	  [[1,30],1 ],
	  [[1,31],4 ],
	  [[1,35],1 ],
	  [[1,36],1 ],
	  [[1,47],7 ],
	  [[1,64],11 ],
	  [[1,66],50 ],//
	  [[1,68],50 ],//
	  [[1,74],11 ],
	  [[1,76],50 ],//
	  [[1,78],50 ],//

	  [[1,81],12 ],//
	  [[1,84],5 ],//
	  [[1,86],56 ],//
	  [[1,88],56 ],//
	  [[1,91],12 ],//
	  [[1,94],5 ],//
	  [[1,96],56 ],//
	  [[1,98],56 ],//
	  [[2,51],1 ],//
];
~osc1 = Range.new(0,10).asArray.removeAll([4]).collect{|el,i| [1,el]};
~noise = Range.new(10,5).asArray.removeAll([14]).collect{|el,i| [1,el]};
~osc2 = Range.new(20,10).asArray.removeAll([24]).collect{|el,i| [1,el]};
~osc_mod = Range.new(30,10).asArray.collect{|el,i| [1,el]};
~filter = Range.new(40,10).asArray.collect{|el,i| [1,el]};
~amp = Range.new(50,10).asArray.removeAll([58,59]).collect{|el,i| [1,el]};
~envf = Range.new(60,10).asArray.collect{|el,i| [1,el]};
~env2 = Range.new(70,10).asArray.collect{|el,i| [1,el]};
~lfo1 = Range.new(80,10).asArray.collect{|el,i| [1,el]};
~lfo2 = Range.new(90,10).asArray.collect{|el,i| [1,el]};

~chorus = Range.new(40,10).asArray.removeAll([47,48,49]).collect{|el,i| [2,el]};
~delay = Range.new(50,10).asArray.removeAll([54,58,59]).collect{|el,i| [2,el]};
~rev = Range.new(60,10).asArray.removeAll([69]).collect{|el,i| [2,el]};

~fxlfo1 = Range.new(80,10).asArray.collect{|el,i| [2,el]};
~fxlfo2 = Range.new(90,10).asArray.collect{|el,i| [2,el]};

~all = ~osc1++~noise++~osc2++~osc_mod++~filter++~amp++~envf++~env2++~lfo1++~lfo2++~chorus++~delay++~rev++~fxlfo1++~fxlfo2;
~fx = ~chorus++~delay++~rev++~fxlfo1++~fxlfo2;

~rndz = {|arr,chan=0|
	{
	arr.do{|el,i|
		var maxv = 127;
		~exept.do{|ell,ii|
			if(ell[0] == el,{
				maxv = ell[1];
			});
		};
	~mout.control(chan,99,el[0]);
	~mout.control(chan,98,el[1]);
	~mout.control(chan,6,rrand(0, maxv));
	0.005.wait;
	};
	}.fork;
	nil;
};

)

(
~rndz.value(~all,3);
~rndz.value(~fx,4);
)


// nrpm test
(
var mout;
MIDIClient.init;
mout = MIDIOut.newByName("Elektron Analog Four", "Elektron Analog Four");
mout.control(0,99,1);
mout.control(0,98,5);
mout.control(0,6,68);
)



