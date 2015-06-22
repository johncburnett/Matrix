(
//****************************************************************************//
//_INIT - do this first or you will be sad

o = s.options;
o.memSize = 8192 * 4;
s.boot;
MIDIIn.connectAll;

// ~soundBuf = Buffer.read(s, "*_*");

//Pattern percussion stuff
~bpm = 20; //<--Set this to taste!-->
//~key=50.midicps;
~beat = 60/~bpm;
//a-d are volum
~vol1 = 0.0;
~vol2 = 0.0;
~vol3 = 0.0;
~vol4 = 0.0;
~bassFreq  = 1;
~snareFreq = 1;
~hatFreq   = 1;
~pitchLen  = 1;
//sequence of patterns to draw from
~duo        = Pseq([~beat/2,~beat/2],1);
~trio       = Pseq([~beat/3,~beat/3,~beat/3],1);
~quartet    = Pseq([~beat/4,~beat/4,~beat/4,~beat/4,],1);
~quarToQuin = Pseq([~beat/4,~beat/4,~beat/4,~beat/8,~beat/8],1);
~quintet    = Pseq([~beat/5,~beat/5,~beat/5,~beat/5,~beat/5],1);
~quinToTrio = Pseq([~beat/5,~beat/5,~beat/5,~beat/15,~beat/3],1);
);





//--------------------------------------------------------------------------------------------------------//





(

//
//****************************************************************************//
//_Generators
(
/**
* No.1 - AudioInput
*
* simple audio input
*/
SynthDef(\audioInput, { |amp = 0.0, choose = 30|
	var input = SoundIn.ar(0).dup;
	//---
	Out.ar(choose, input * amp);
}).load(s);

//---------------------

/**
* No.2 - Droplet
*
* pitch envelope-based synth
*/
SynthDef(\droplet, { |amp = 0.7, choose = 30, gate = 0, freq = 3000, dur = 1|
	var sound,volEnv,pitchEnv;
	pitchEnv=EnvGen.ar(Env.new([0.9,0.7,1,1],[0.06,0.05,0.89]*dur,\exponential), gate);
	volEnv=EnvGen.ar(Env.new([0,1,0.8,0.0],[0.2,0.05,0.75]*dur), doneAction:2);
	sound=SinOsc.ar(freq*pitchEnv,mul:volEnv);
	Out.ar(choose, Pan2.ar(sound) * amp);
}).load(s);

//---------------------

/**
* No.3 - Butter
*
* ~Sawtooth Synth
*/
SynthDef(\butter,{ |amp = 0.7, choose = 30, gate = 0, freq = 300, dur = 1|
	var env, tone;
	env = Env.new([0, 0.8, 0], [dur/16, dur/16 * 15], \lin);
	env = EnvGen.ar(env, doneAction:2);
	tone = SinOsc.ar( freq * (1,3..10) * 0.95, mul:(1/5) ).sum.dup;
	tone = Clip.ar(tone, 0, 0.8);
	tone = HPF.ar(tone, freq*3);
	Out.ar(choose, amp * env * tone);
}).load(s);

//---------------------

/**
* No.4 - phaseMod
*
* Phase modulation
*/
SynthDef(\phaseMod,{ |amp = 0.0, choose = 30, freq = 30|
	var fund, oscA, oscB, pm;
	fund = 40.midicps;
	oscA = PMOsc.ar(fund, fund / 2.05, 2pi * 0.1);
	oscB = SinOsc.ar(fund / 2.01, oscA * 2pi * 0.5);
	pm = SinOsc.ar(fund / 2.02, oscB * 2pi * 0.8);
	Out.ar(choose, pm!2);
}).load(s);

//---------------------

/**
* No.5 - noise
*
* to be implemented
*/
SynthDef(\noise,{ |amp = 0.0, choose = 30|
	Out.ar(choose, WhiteNoise.ar(0.8)!2 * amp);
}).load(s);

//---------------------

/**
* No.6 - patPerc
*
* Pattern percussion - bass, snare, hat, pitch
*
* TODO - make synths static, integrate with routines
*/



//****************************************************************************//
//_Processors

/**
* No.1 - DopPanner
*
* lo-fi doppler panner
*/
SynthDef(\dopPan, { |amp=0.0, gestureNum=0, gestureLen=1, depth=0.3, panShape=0.1, direction=1, tail=3|
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
	var sound,trig,freqShift,audioEnv,dopEnv,pan,panDelta, mix,mix2,bands;
	//---
	sound = In.ar(50, 2).sum;//choose input freq range (0-4)
	trig=Pulse.kr(Array.fill(10,{1.0.rand}),0.4).sum;
	//---
	pan=EnvGen.kr(Env.new([1.0,0.0,-1.0],[gestureLen*panShape,gestureLen*(1-panShape)],curve:\sine),trig);
	panDelta=EnvGen.kr(Env.new([1,1.0+depth,1-(depth*1.5)],[gestureLen*panShape,gestureLen*(1-panShape)],[3,1]),trig);
	//pitch shifted up as it nears the center, and down as it passes the center
	audioEnv=EnvGen.kr(Env.new([0.0,1,0.0],[gestureLen*panShape,gestureLen*(1-panShape)],[-3,-6]),trig);
	freqShift=PitchShift.ar(sound,windowSize: 0.1,pitchRatio:panDelta);
	//the faster the pan, the larger the freq difference (can be neg.)
	//---
	mix = Pan2.ar(freqShift,pan*direction);
	//mix2 = 0.7*DelayC.ar(Pan2.ar(shift,1-pan));//inverted and delayed panning to fill out the stereo field
	Out.ar(80, (mix)*audioEnv*amp)
	}
).load(s);

//---------------------

/**
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
	Out.ar(82, mix * amp);
}).load(s);

//---------------------

/**
* No.3 - octoVerb
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

	Out.ar(84, reverb * amp);
}).load(s);

//---------------------

/**
* No.4 - combShift
*
* Bends pitch into a double wedge
* according to amplitude and
* then comb filters each bend
* according to frequency.
*/
SynthDef("combShift",{ |amp = 0.95|
	var ampMap, pitchMap, p1, p2, p3, p4;

	var input, low, lowmid, highmid, high;
	input   = In.ar(56, 2);
	low     = BBandPass.ar(input,250,0.25);
	lowmid  = BBandPass.ar(input,1000,0.25);
	highmid = BBandPass.ar(input,4000,0.25);
	high    = BBandPass.ar(input,8000,0.25);

	//amplitude mapping to pitch ratio
	ampMap = Amplitude.kr(input[0]);
	//pitch mapping to delay time
	pitchMap = Lag.kr(LinLin.kr(Pitch.kr(input[0]), 0, 3000, 0.1, 0.5), 0.05);

	p1 = CombC.ar(
		PitchShift.ar(
			low,
			pitchRatio:LinLin.ar(ampMap, 0.0, 1.0, 1.0, 2.0)
		),
		2.0,
		pitchMap,
		Rand(0.25, 2.0),
		0.45
	);

	p2 = CombC.ar(
		PitchShift.ar(
			high,
			pitchRatio:LinLin.ar(ampMap, 0.0, 1.0, 1.0, 0.1)
		),
		2.0,
		pitchMap * 0.9,
		Rand(0.25, 2.0),
		0.45
	);

	p3 = CombC.ar(
		PitchShift.ar(
			lowmid,
			pitchRatio:LinLin.ar(ampMap, 0.0, 1.0, 1.0, 1.5)
		),
		2.0,
		pitchMap * 1.1,
		Rand(0.25, 2.0),
		0.45
	);

	p4 = CombC.ar(
		PitchShift.ar(
			highmid,
			pitchRatio:LinLin.ar(ampMap, 0.0, 1.0, 1.0, 0.5)
		),
		2.0,
		pitchMap * 0.8,
		Rand(0.25, 2.0),
		0.45
	);

	Out.ar(86, [(p1 + p2), (p3 + p4)] * amp);
}).load(s);

//---------------------

/**
* No.5 - combFilter
*
* Standard Comb Filter
* -gives specific resonanct
* -frequency to input
* -signal
*/
SynthDef(\combFilter,{ |amp = 0.0, frequency = 30, resonance = 1, octaves = 10, lagTime = 3|
	var in, delay, delayTime, comb;
	in = In.ar(58, 2);
	delayTime = Lag.kr(1/frequency, lagTime);
	delay = CombC.ar(in, delaytime:delayTime, decaytime:resonance) * 0.4;
	// delay = LPF.ar(delay, frequency * octaves * 10);
	comb = in + delay;
	// comb = HPF.ar(comb, frequency * 4);
	Out.ar(88, comb * amp);
}).load(s);

//---------------------

/**
* No.6 - directOut
*
* ->Input straight to output
*/
SynthDef(\directOut, { |amp = 0.0|
	var in = In.ar(60,2);
	Out.ar(90, in * amp);
}).load(s);


//****************************************************************************//
//_Output Module

SynthDef(\output, { |amp = 0.9|
	var in0,in1,in2,in3,in4,in5,mix;
	//
	in0 = In.ar(80, 2); //all inputs are stereo
	in1 = In.ar(82, 2);
	in2 = In.ar(84, 2);
	in3 = In.ar(86, 2);
	in4 = In.ar(88, 2);
	in5 = In.ar(90, 2);
	//

	// mix = Mix.ar(2, [in0, in1, in2, in3, in4, in5] / 6);
	mix = (in0 + in1 + in2 + in3 + in4 + in5) / 3;
	Out.ar(0, mix);
}).load(s);


//****************************************************************************//
//_Instantiate synths

//output
~output=Synth.tail(1,\output);


//processors
~directOut  = Synth.before(~output,\directOut);
~dopPan     = Synth.before(~output,\dopPan);
~octoVerb   = Synth.before(~output,\octoVerb);
~splatDelay = Synth.before(~output,\splatDelay);
~combShift  = Synth.before(~output,\combShift);
~combFilter = Synth.before(~output,\combFilter);

//generators
~audioInput = Synth.before(~directOut,\audioInput);
~droplet    = Synth.before(~directOut,\droplet);
~butter     = Synth.before(~directOut,\butter);
~phaseMod   = Synth.before(~directOut,\phaseMod);
~noise      = Synth.before(~directOut,\noise);
~patternPerc= 0;//
~null       = 0;

/*^^^PatternPercussion will implemented at some point, but we do not have the time at this moment.
~bass       = Synth(\bass);
~snare      = Synth(\snare);
~hat        = Synth(\hat);
~pitch      = Synth(\pitch);
~patPerc    = [~bass, ~snare, ~hat, ~pitch];*/

~generators = [~audioInput, ~droplet, ~butter, ~phaseMod, ~noise,~null];
~processors = [~dopPan, ~splatDelay, ~octoVerb, ~combShift, ~combFilter, ~directOut];

//****************************************************************************//

);

// ~phaseMod.set(\choose, 52)
//
// ~phaseMod.set(\amp, 1)
// ~s.set(\amp, 1);
// ~directOut.set(\amp, 1);



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

s.meter;


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

		sliderSet[i].action = { |obj|
			val.value_((sliderSet[i].value * 1000).round / 1000)
		};

		valueSet[i] = val;
	});

	[sliderSet, valueSet];
};


//****************************************************************************//
//_Matrix Generator

~matrixGen = { |n=6, m=6, x=0, y=0, width=400|
	var buttonSet = Array.fill(n, { Array.newClear(m)});

	for(0, n-1, { |i|
		for(0, m-1, { |j|
			var div = (width - 40) / n;

			buttonSet[i][j] = Button(w, Rect(
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


//generate matrices
~matrix = ~matrixGen.value(6, 6, 2*~width/3 + 30, 0, ~height/2);

/**
* Link matrix routing
*

HEY JOHN, ITS PAULUS. I HAVE PUT THE ROUTINE IN THE CODE UP ABOVE. THERE IS COMMENTING THERE BUT BASICALLY YOU HAVE TO SEND A MESSAGE TO "~whichSynth" with the number of the synth you want to send the rhythmic gate messages to... Droplet is 2, Butter is 3 and PatternPerc is 6 [BUT remember to correnct for zero-indexing!].

ALSO I NOTICED: NOTHING IS ACTUALLY GOING TO THE EFFECTS YET, RIGHT? THE ENTIRE COLUMN GOES TO DIRECT OUT PUT I THINK...

* Second parameter of generators must be bus number
*/
~asyncValues = { |synth|
	var x = (), d = SynthDescLib.global[synth.defName.asSymbol];
	d.notNil.if { d.controls.do { |c|  synth.get(c.name,  { |y|
		x.put(c.name, y) }) } };
	x
};

~syncValues = { |synth|
	var x = (), d = SynthDescLib.global[synth.defName.asSymbol];
	d.notNil.if { d.controls.do { |c| x.put(c.name, c.defaultValue) } };
	x
};

for(0, 5,{ |i|
	for(0, 5,{ |j|
		var port = (50 + (j*2));

		~matrix[i][j].action = { |obj|

			if( ~matrix[i][j].value == 1, {
				port = (50 + (j*2));
				~generators[i].set(\choose, port);
				(~generators[i].defName + "--->" + ~processors[j].defName + " (" + port + ")").postln;
				},{
					~generators[i].set(\choose, 30);
					(~generators[i].defName + "-/->" + ~processors[j].defName + " (" + port + ")").postln;
			});

			for(0, 5, { |k|
				if( k != j, { ~matrix[i][k].value = 0; } );
			});
		};
	});
});

~makeOneShot = { |column|
	for(0, 5, { |i|
		var button = ~matrix[column][i];

		button.states_([
			["", Color(1,1,0.51),Color.grey]
		]);

		button.action = {
			var port, generator, processor;
			port = (50 + (i*2));
			processor = ~processors[i];
			if( column == 1, { generator = \droplet }, { generator = \butter } );
			(generator + "--->" + processor.defName + " (" + port + ")").postln;
			Synth(generator, [\choose, port]);
		};
	});
};

~makeOneShot.(1);
~makeOneShot.(2);


/**
* Link Amplitudes
*/
for(0, ~generators.size-1,{ |i|
	~sliderSet[i][0][0].action = { |obj|
		var synth = ~generators[i];
		NodeControl(synth, 0).value = obj.value;
		~sliderSet[i][1][0].value_((obj.value * 1000).round / 1000);
	};
});

for(0, ~processors.size-1,{ |i|
	~sliderSet[i + 6][0][0].action = { |obj|
		var synth = ~processors[i];
		synth.defName.postln;
		NodeControl(synth, 0).value = obj.value;
		~sliderSet[i + 6][1][0].value_((obj.value * 1000).round / 1000);
	};
});

);


)
