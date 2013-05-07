(
~fftsize=4096;
//~fftsize=512;
//~fftsize = 4096;
{
	/*
	var ir, irbuffer, bufsize;
	ir = ([1] ++0.dup(100) ++ ((1, 0.99998 .. 0).collect{|f| f =
    f.squared.squared; f = if(f.coin){0}{f.squared}; f =
    if(0.5.coin){0-f}{f} } * 0.1)).normalizeSum;
	*/

	a = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/impulses/test/a.wav");
	b = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/impulses/test/b.wav");
	c = Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/impulses/test/c.wav");
	//irbuffer = Buffer.loadCollection(s, ir);

    s.sync;

    //bufsize= PartConv.calcBufSize(~fftsize, irbuffer);
	~low = Buffer.alloc(s, PartConv.calcBufSize(~fftsize,a), 1);
	~neu = Buffer.alloc(s, PartConv.calcBufSize(~fftsize,b), 1);
	~hi = Buffer.alloc(s, PartConv.calcBufSize(~fftsize,c), 1);

    ~low.preparePartConv(a, ~fftsize);
	~neu.preparePartConv(b, ~fftsize);
	~hi.preparePartConv(c, ~fftsize);

    s.sync;

    a.free; b.free; c.free;

}.fork;
)


s.prepareForRecord;
s.record;
s.stopRecording;

(

~target= Buffer.read(s, "/Users/nunja/Documents/AudioLib/supercollider/raw/juno.wav" );

{ var dry, wet, lo_p, neu_p, hi_p, kernel;

	dry = PlayBuf.ar(2, ~target, BufRateScale.kr(~target)/2, loop:1) * 0.7;
	lo_p = PartConv.ar(dry, ~fftsize, ~low.bufnum, 0.1);
	hi_p = PartConv.ar(dry, ~fftsize, ~hi.bufnum, 0.3);
	neu_p = PartConv.ar(dry, ~fftsize, ~neu.bufnum, 0.09);
	////neu_p = Convolution2.ar(dry, a, 1, ~fftsize)*0.06;
	//neu_p = Convolution2.ar(dry, b, 1, ~fftsize)*0.6;
	//hi_p = Convolution2.ar(dry, c, 1, ~fftsize)*0.1;

	//wet = HPF.ar(neu_p, 100);
	//wet = LPF.ar(wet, 12000);
	wet = (neu_p+lo_p)*0.3;

	Out.ar(0,  SelectX.ar( 2, [dry,wet]));



}.freqscope;

)
