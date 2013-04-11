(
//~fftsize=2048;
//~fftsize=8192;
~fftsize = 4096;
{
	var ir, irbuffer, bufsize;
	ir = ([1] ++0.dup(100) ++ ((1, 0.99998 .. 0).collect{|f| f =
    f.squared.squared; f = if(f.coin){0}{f.squared}; f =
    if(0.5.coin){0-f}{f} } * 0.1)).normalizeSum;

	//irbuffer= Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/impulses/lp6khz.wav");
	//irbuffer = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/impulses/hp68hz36db.wav");
	irbuffer = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/impulses/68hz20db.wav");
	//irbuffer = Buffer.loadCollection(s, ir);

    s.sync;

    bufsize= PartConv.calcBufSize(~fftsize, irbuffer);

    ~irspectrum= Buffer.alloc(s, bufsize, 1);

    ~irspectrum.preparePartConv(irbuffer, ~fftsize);

    s.sync;

    irbuffer.free;

}.fork;
)

(

~target= Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/test/test.wav" );
{ var dry, wet, kernel;

dry = PlayBuf.ar(1, ~target, loop:1) * 0.2;
wet = PartConv.ar(dry, ~fftsize, ~irspectrum.bufnum, 0.5) * 0.2;

	Out.ar(0,  SelectX.ar( MouseX.kr(0, 1) * 2, [dry,wet]) ! 2);

}.play;

)
