(
//****************************************************************************//
//_Window

~width = 800;
~height = 600;

w = Window("GUI", Rect(
	Window.screenBounds.width/2 - (~width/2),
	Window.screenBounds.height/2 - (~height/2),
	~width,
	~height
))
.background_(Color(0.1, 0.1, 0.1))
.front
.alwaysOnTop_(true);

//****************************************************************************//
//_Sliders
//TODO: set coordinates, labels, title

~sliderGen = { |width = 800, height = 600, x = 0, y = 0, numSliders = 10|
	var sliderSet = Array.newClear(numSliders);
	var valueSet = Array.newClear(numSliders);

	for(0, numSliders-1,{ |i|
		var div, val;

		div = (width - 40) / numSliders;
		sliderSet[i] = Slider(w, Rect(
			(div * i) + 20 + x,
			20 + y,
			div - 10,
			height - 60
		))
		.background_(Color(0, 0, 0.15))
		.knobColor_(Color.black);

		val = TextField(w, Rect(
			(div * i) + 20 + x,
			height - 40 + y,
			div - 10,
			20
		))
		.value_(0);

		sliderSet[i].action= { |obj|
			val.value_((sliderSet[i].value * 1000).round / 1000)
		};

		valueSet[i] = val;
	});

	[sliderSet, valueSet];
};

/*~sliders1 = ~sliderGen.value(400, 300, 0, 0, 5);
~sliders2 = ~sliderGen.value(400, 300, 400, 0, 5);
~sliders3 = ~sliderGen.value(400, 300, 0, 300, 5);
~sliders4 = ~sliderGen.value(400, 300, 400, 300, 5);*/
);



(
//****************************************************************************//
//_Integrate synths w/ GUI

(
//_Input Module
SynthDef(\input, { |inAmp=0, b1Amp=0, b2Amp=0, b3Amp=0, b4Amp=0|
	//pre process the input signal into different frequency bands
	var input,band1,band2,band3,band4;
	input = AudioIn.ar(1);//supposed to be vocals
	//input = GrainFM.ar(1,Impulse.ar(2/0.2),0.2,);
	//input = Saw.ar(200);
	//---
	//would like to do this with FFT filtering if possible...
	band1 = BBandPass.ar(input,250,0.25);
	band2 = BBandPass.ar(input,1000,0.25);
	band3 = BBandPass.ar(input,4000,0.25);
	band4 = BBandPass.ar(input,8000,0.25);
	//---
	Out.ar(50, input * inAmp);//original signal
	Out.ar(51, band1 * b1Amp);//low band
	Out.ar(51, band2 * b2Amp);//lowmid
	Out.ar(53, band3 * b3Amp);//highmid
	Out.ar(54, band4 * b4Amp)//high
}).add;


//_Generic Processing Module
SynthDef(\gen_Process, { |inAmp=0, b1Amp=0, b2Amp=0, b3Amp=0, b4Amp=0|
	var full,low,lowmid,highmid,high,input, band1, band2, band3, band4;
	//
	full = In.ar(50)!2; //all inputs are stereo
	low = In.ar(51)!2;
	lowmid = In.ar(52)!2;
	highmid = In.ar(53)!2;
	high = In.ar(54,2)!2;
	//
	//PROCESS!!
	//
	input=band1=band2=band3=band4=0;
	Out.ar(100, input * inAmp);
	Out.ar(102, band1 * b1Amp);
	Out.ar(104, band2 * b2Amp);
	Out.ar(106, band3 * b3Amp);
	Out.ar(108, band4 * b4Amp);
}).add;


//_Output Module
SynthDef(\output, {
	arg amp = 1.0;
	var in0,in1,in2,in3,in4,
	mix,mix2,mix3,mix4;
	//
	in0 = In.ar(100,2); //all inputs are stereo
	in1 = In.ar(102,2);
	in2 = In.ar(104,2);
	in3 = In.ar(106,2);
	in4 = In.ar(108,2);
	//

	mix = in0;//in1+in2+in3+in4; //...etc
	Out.ar(0, mix);
}).add;
);

(
//_Instantiate synths w/ GUI components

~liveIn = Synth(\input);
~sliders1 = ~sliderGen.value(400, 300, 0, 0, 5);
for (0, 4, { |i|
	~sliders1[0][i].action = { |obj|
		NodeControl(~liveIn, i).value_(obj.value);
		~sliders1[1][i].value_((obj.value * 1000).round / 1000);
	};
});

~process = Synth(\gen_Process);
~sliders2 = ~sliderGen.value(400, 300, 0, 300, 5);
for (0, 4, { |i|
	~sliders2[0][i].action = { |obj|
		NodeControl(~process, i).value = obj.value;
		~sliders2[1][i].value_((obj.value * 1000).round / 1000);
	};
});

~out = Synth(\output);


);

)












