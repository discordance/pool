////////#superCollider///////////
//////////////////////10_dic_2011
///////  paisaje Espanol
///// audio @ http://www.archive.org/details/PaisajeEspanol
/////// escala  A| B| C| D| E| F| G#| A  menorArmonica
///////        57|59|60|62|64|65| 68|69 //////////////
s.boot;
s.scope;
s.meter;
FreqScope.new;
//
s.record;
////////
(// *
(//fx
SynthDef(\master,{|gate=1|
	var fx,env;
		fx=In.ar(20);
		fx=GVerb.ar(fx,24,3,0.2,mul:0.3);
		env=EnvGen.ar(Env.asr(0.01,0.98,0.01),gate,doneAction:2);
	Limiter.ar(Out.ar(0,Pan2.ar(fx*env,[0.92,-0.92])),0.75);
}).add;
);
(//acordes
SynthDef(\inst,{|gate=1,nota1,nota2,nota3,nota4,rel|
	var cuerda,env;
		cuerda=HPF.ar(
			Limiter.ar((LFTri.ar(nota1.midicps,0,0.7)+SinOsc.ar(nota2.midicps,0.2,0.6)+
			SinOsc.ar(nota3.midicps,-0.2,0.5)+SinOsc.ar(nota4.midicps,0.1,0.5))
				+LFTri.ar(Mix(nota1.midicps,nota2.midicps,nota3.midicps,nota4.midicps),0,0.5),
			0.9),
			200,0.75);
		env=EnvGen.ar(Env.perc(0.015,rel),gate,doneAction:2);
	Out.ar([0,20],Pan2.ar(cuerda*env,[0.1,-0.9]))
}).add;
);
(//melodia
SynthDef(\inst2,{|gate=1,nota1|
	var cuerda2,env;
		cuerda2=Limiter.ar(SinOsc.ar(nota1.midicps,0,0.1)+
				Saw.ar(nota1.midicps,0.1,0.06)+
					RLPF.ar(
				LFCub.ar(nota1.midicps,0.1,0.1)+
				LFTri.ar(nota1.midicps,0.1,0.2),
					Phasor.kr(Impulse.kr(1),60,10000),
					0.5),
			0.2);
		env=EnvGen.ar(Env.perc(0.01,0.15),gate,doneAction:2);
	Out.ar(20,Pan2.ar(cuerda2*env,[0.9,-0.82]))
}).add;
);
////
(
Tdef(\acordes,{
	var c=0,fund,primerg,segundog,tercerg,cuartog,quintog,sextog,septimog,tiempo,trans,release;
	Synth(\master);//sinte master
	~acorde=Array.newClear(4);//1a,3a,5ta,7ma
	~a=[45,47,48,50,52,53,56,57,59,60,62,64,65,68,69,71,72,74,76,77,80,81,83,84,86,88,89,92,93];//escala 4 octavas
        primerg=~a[0];//1er grado
	segundog=~a[1];//2do grado
	tercerg=~a[2];//3er grado
	cuartog=~a[3];//4to grado
	quintog=~a[4];//5to grado
	sextog=~a[5];//6to grado
	septimog=~a[6];//7mo grado
	tiempo=Pwrand([0.25,0.5,0.75,1,2],[0.35,0.45,0.05,0.1,0.05],inf).asStream;
	release=Pwrand([0.25,0.5,0.75,1],[0.1,0.5,0.2,0.2],inf).asStream;
	inf.do{
		c=c+1;
		fund=Array.series(7,0);//fundamentales posibles la primera octava
		~numfund=fund.scramble.pyramid.mirror2.reverse[c%fund.size];//grado de la escala
		//~numfund.postln;
		~acorde.put(0,~a[~numfund]);//pone en la tonica algun grado de la escala
		trans=[0,0,12,24,36,0].choose;
		//trans.postln;
		if((~acorde[0]+trans)==(primerg+trans),{//Am7
				~acorde.put(1,~a[~numfund]+3);//menor
				~acorde.put(2,~a[~numfund]+7);//5ta justa
				~acorde.put(3,~a[~numfund]+11)//7ma mayor
				}
		);
		if((~acorde[0]+trans)==(segundog+trans),{//Bm5b7m
				~acorde.put(1,~a[~numfund]+3);//menor
				~acorde.put(2,~a[~numfund]+6);//5ta disminuida
				~acorde.put(3,~a[~numfund]+10)//7ma menor
				}
		);
		if((~acorde[0]+trans)==(tercerg+trans),{//C5#7
				~acorde.put(1,~a[~numfund]+4);//mayor
				~acorde.put(2,~a[~numfund]+8);//5ta aumentada
				~acorde.put(3,~a[~numfund]+11)//7ma mayor
				}
		);
		if((~acorde[0]+trans)==(cuartog+trans),{//Dm7m
				~acorde.put(1,~a[~numfund]+3);
				~acorde.put(2,~a[~numfund]+7);
				~acorde.put(3,~a[~numfund]+10)
				}
		);
		if((~acorde[0]+trans)==(quintog+trans),{//E7m
				~acorde.put(1,~a[~numfund]+4);
				~acorde.put(2,~a[~numfund]+7);
				~acorde.put(3,~a[~numfund]+10)
				}
		);
		if((~acorde[0]+trans)==(sextog+trans),{//F7
				~acorde.put(1,~a[~numfund]+4);
				~acorde.put(2,~a[~numfund]+7);
				~acorde.put(3,~a[~numfund]+11)
				}
		);
		if((~acorde[0]+trans)==(septimog+trans),{//G#5b7dis
				~acorde.put(1,~a[~numfund]+3);
				~acorde.put(2,~a[~numfund]+6);
				~acorde.put(3,~a[~numfund]+9)//7ma disminuida
				}
		);
		~acorde.postln;
		~ins=Synth(\inst);
		~ins.set(\nota1,~acorde[0]);
		~ins.set(\nota2,~acorde[1]);
		~ins.set(\nota3,~acorde[2]);
		~ins.set(\nota4,~acorde[3]);
		~ins.set(\rel,release.next);
		tiempo.next.wait
		}
});
);
(
Tdef(\melodia,{
	var c=0,quinta,
		tiempo=Pwrand([0.25,0.5,1,0.0125],[0.35,0.6,0.25,0.025],inf).asStream;
	inf.do{
		~amel=[57,59,60,62,64,65,68,69,71,72,74,76,77,80,81,83,84,86,88,89,92,93];//3 octavas
		c=c+1;
		~numel=~amel.scramble[c%~amel.size];
		~numel.postln;
		quinta=[0,0,7,12,0].choose;//se transpone una quinta u octava
		~ins2=Synth(\inst2);
		~ins2.set(\nota1,~numel+quinta);
		tiempo.next.wait
		}
});
);
)
(//
Tdef(\acordes).play;
Tdef(\melodia).play;
)
Tdef(\melodia).stop;
Tdef(\acordes).stop;
s.stopRecording;