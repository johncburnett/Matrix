( // do this first or you will be sad
o = s.options;
o.memSize = 8192 * 4;
s.boot;
);










(



(
//****************************************************************************//
//_Generators

/*
* No.1 - AudioInput
*
* simple audio input
*/
SynthDef(\audioInput, { |input, choose=50|
	var outputList;
	input = AudioIn.ar(1).dup;//supposed to be vocals
	//---
	Out.ar(choose,input);//original signal
}).load(s);

//---------------------

/*
* No.2 - Droplet
*
* pitch envelope-based synth
*/
SynthDef(\droplet, {
	//work in progress\\
	arg freq=3000, dur=0.5, intensity, choose=50;
	var sound,volEnv,pitchEnv;
	pitchEnv=EnvGen.ar(Env.new([0.9,0.7,1,1],[0.06,0.05,0.89]*dur,\exponential),doneAction:2);
	volEnv=EnvGen.ar(Env.new([0,1,0.8,0.0],[0.2,0.05,0.75]*dur));
	sound=SinOsc.ar(freq*pitchEnv,mul:volEnv);
	Out.ar(choose,sound);
}).load(s);

//---------------------

/*
* No.3 - Butter
*
* ~Sawtooth Synth
*/
SynthDef(\butter,{ |freq = 30, amp = 0.95, dur = 1, choose=50|
	var env, tone;
	env = Env.new([0, 0.8, 0], [dur/16, dur/16 * 15], \lin);
	env = EnvGen.ar(env, doneAction:2);
	tone = SinOsc.ar( freq * (1,3..10) * 0.95, mul:(1/5) ).sum.dup;
	tone = Clip.ar(tone, 0, 0.8);
	tone = HPF.ar(tone, freq*3);
	Out.ar(choose, env * tone);
}).load(s);


//****************************************************************************//
//_Processors

/*
* No.1 - DopPanner
*
* lo-fi doppler panner
*/
SynthDef(\dopPan, {
	      //_*argument desecriptions*_\\
	     //============================\\
	//_gestureNum_ indicates the shape of the pan
	//_gestureLen_ determines length of the pan gesture
	//_depth_ represents the max freq change from the doppler effec
	/*_panShape_ determines balance between "approach" panning (pitchshift up) and "depart" panning (pitchshift down);
	  _panShape_ range: 0.0 < range > 1.0; closer to 0 is a quicker approach, and vice versa
	*/
	//if _direction_ == 1, pan is L -> R; if direction == -1, pan is R -> L
	//tail determines the length of the fade out/assoc. pitchshift downwards...
	arg gestureNum=0, gestureLen = 1, depth = 0.3, panShape = 0.1, direction = 1, amp = 0.2, tail = 3;
	var sound,freqShift,audioEnv,dopEnv,pan,panDelta, mix,mix2,bands;
	//---
	sound = In.ar(50, 2).sum;//choose input freq range (0-4)
	//---
	pan=EnvGen.kr(Env.new([1.0,0.0,-1.0],[gestureLen*panShape,gestureLen*(1-panShape)],curve:\sine));
	panDelta=EnvGen.kr(Env.new([1,1.0+depth,1-(depth*1.5)],[gestureLen*panShape,gestureLen*(1-panShape)],[3,1]));
	//pitch shifted up as it nears the center, and down as it passes the center
	audioEnv=EnvGen.kr(Env.new([0.0,1,0.0],[gestureLen*panShape,gestureLen*(1-panShape)],[-3,-6]),doneAction:2);
	freqShift=PitchShift.ar(sound,windowSize: 0.1,pitchRatio:panDelta);
	//the faster the pan, the larger the freq difference (can be neg.)
	//---
	mix = Pan2.ar(freqShift,pan*direction);
	//mix2 = 0.7*DelayC.ar(Pan2.ar(shift,1-pan));//inverted and delayed panning to fill out the stereo field
	Out.ar(100, (mix)*audioEnv*amp) //~~RemembeR! audio buss #14 doesn't work! Skip it~~
	}
).add;

//---------------------

/*
* No.2 - SplatDelay
*
* break the sound; splat the sound
*/
SynthDef(\splatDelay,{ |amp = 0.0|
	var in, delay1, delay2, mix;
	in = In.ar(52, 2);

	delay1 = Array.fill( 12,{
		CombC.ar(in[0], 0.8, rrand(0.005, 0.1), 2)
	}).sum / 12;

	delay2 = Array.fill( 12,{
		CombC.ar(in[1], 0.8, rrand(0.005, 0.1), 2)
	}).sum / 12;

	mix = [delay1, delay2];
	Out.ar(102, mix * amp);
}).load(s);

//---------------------

/*
* No.3 - OctoVerb
*
* 8-channel multi-band reverb
*/
SynthDef(\octoVerb,{ |amp = 0.0|
	var input, in, predelay, reverb, full, low, lowmid, highmid, high;

	input   = In.ar(54, 2);
	low     = BBandPass.ar(input,250,0.25);
	lowmid  = BBandPass.ar(input,1000,0.25);
	highmid = BBandPass.ar(input,4000,0.25);
	high    = BBandPass.ar(input,8000,0.25);

	in = [low + highmid, lowmid + high];
	predelay = DelayN.ar(in, 0.1, [0.044, 0.048, 0.052, 0.526]);
	reverb = Mix.ar(Array.fill(7,{ CombL.ar(predelay, 0.05, rrand(0.03, 0.05), 15) }));
	6.do({ reverb = AllpassN.ar(reverb, 0.050, rrand(0.03, 0.05), 1) });

	Out.ar(104, reverb * amp);
}).load(s);


//****************************************************************************//
//_Output Module

SynthDef(\output, { |amp = 0.95|
	var in0,in1,in2,in3,in4,in5,mix;
	//
	in0 = In.ar(100, 2); //all inputs are stereo
	in1 = In.ar(102, 2);
	in2 = In.ar(104, 2);
	in3 = In.ar(106, 2);
	in4 = In.ar(108, 2);
	in5 = In.ar(110, 2);
	//

	mix = Mix.ar(2, [in0, in1, in2, in3, in4, in5]);
	Out.ar(0, mix);
}).add;


//****************************************************************************//
//_Instantiate synths

//output
~output     = Synth(\output);

//processors
~dopPan     = Synth(\dopPan);
~splatDelay = Synth(\splatDelay);
~octoVerb   = Synth(\octoVerb);

//generators
~audioInput = Synth(\audioInput);
~droplet    = Synth(\droplet);
~butter     = Synth(\butter);

);





(
//****************************************************************************//
//_Window

~width = 1280;
~height = 720;

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
//_Slider Generator

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


//****************************************************************************//
//_Matrix Generator

~matrixGen = { |n=6, m=6, x=0, y=0, width=400, height=400|
	var buttonSet = Array.fill(n, { Array.newClear(m)});

	for(0, n-1, { |i|
		for(0, m-1, { |j|
			var div = (width - 40) / n;

			buttonSet = Button(w, Rect(
				(div * i) + 20 + x,
				(div * j) + 20 + y,
				div-10,
				div-10
			))
			.states_([
				["", Color(1,1,0.51),Color.grey],
				["", Color.grey,Color(1,1,0.51)]
			]);
		});
	});
	buttonSet;
};

// ~matrixGen.value(6, 6, 540, 0, 400, 400);


//****************************************************************************//
//_GUI design

//draw dividers
w.drawFunc_{
	Pen.strokeColor = Color.white;
	Pen.width = 2;

	Pen.line( (2*~width/3)@0, (2*~width/3)@~height );
	Pen.stroke;

	for(1, 2,{ |i|
		Pen.line( (i*2*~width/9)@0, (i*2*~width/9)@~height );
		Pen.stroke;
	});

	for(1, 3,{ |i|
		Pen.line( 0@(i*~height/4), (2*~width/3)@(i*~height/4) );
		Pen.stroke;
	});
};

//generate sliders
~sliderSet = Array.newClear(12);
p = 0;
for(0, 3,{ |i|
	for(0, 2,{ |j|
		~sliderSet[p] = ~sliderGen.value(
			(2*~width/9),
			(~height/4),
			(j*2*~width/9),
			(i*~height/4),
			4
		);
		p = p + 1;
	});
});

//generate matrix
~matrix = ~matrixGen.value(6, 6, 2*~width/3, 0, ~width/3, 0);



);



)
