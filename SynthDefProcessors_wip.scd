//Here are the SynthDef Processors

//---------------------

/*
* No.1 - DopPanner
*
* lo-fi doppler panner
*/
SynthDef(\DopPan, {
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
	sound = In.ar(20);//choose input freq range (0-4)
	//---
	pan=EnvGen.kr(Env.new([1.0,0.0,-1.0],[gestureLen*panShape,gestureLen*(1-panShape)],curve:\sine));
	panDelta=EnvGen.kr(Env.new([1,1.0+depth,1-(depth*1.5)],[gestureLen*panShape,gestureLen*(1-panShape)],[3,1]));//pitch shifted up as it nears the center, and down as it passes the center
	audioEnv=EnvGen.kr(Env.new([0.0,1,0.0],[gestureLen*panShape,gestureLen*(1-panShape)],[-3,-6]),doneAction:2);
	freqShift=PitchShift.ar(sound,windowSize: 0.1,pitchRatio:panDelta);//the faster the pan, the larger the freq difference (can be neg.)
	//---
	mix = Pan2.ar(freqShift,pan*direction);
	//mix2 = 0.7*DelayC.ar(Pan2.ar(shift,1-pan));//inverted and delayed panning to fill out the stereo field
	Out.ar(10, (mix)*audioEnv*amp) //~~RemembeR! audio buss #14 doesn't work! Skip it~~
	}
).add;

//---------------------

/*
* No.2 - SplatDelay
*
* break the sound; splat the sound
*/
SynthDef(\SplatDelay,{
	var in, delay1, delay2, mix;
	in = In.ar(30, 2);

	delay1 = Array.fill( 12,{
		CombC.ar(in[0], 0.8, rrand(0.005, 0.1), 2)
	}).sum / 12;

	delay2 = Array.fill( 12,{
		CombC.ar(in[1], 0.8, rrand(0.005, 0.1), 2)
	}).sum / 12;

	mix = [delay1, delay2];
	Out.ar(100, mix);
}).load(s);

//---------------------

/*
* No.3 - OctoVerb
*
* 8-channel multi-band reverb
*/
SynthDef("OctoReverb",{ |amp = 0.0|
	var in, predelay, reverb;

	var full, low, lowmid, highmid, high;
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

//---------------------

/**
* No.4 - CombShift
*
* Bends pitch into a double wedge
* according to amplitude and
* then comb filters each bend
* according to frequency.
*/
SynthDef("CombShift",{ |amp = 0.95|
	var ampMap, pitchMap, p1, p2, p3, p4;

	var full, low, lowmid, highmid, high;
	full = In.ar(50)!2;
	low = In.ar(51)!2;
	lowmid = In.ar(52)!2;
	highmid = In.ar(53)!2;
	high = In.ar(54)!2;

	//amplitude mapping to pitch ratio
	ampMap = Amplitude.kr(full[0]);
	//pitch mapping to delay time
	pitchMap = Lag.kr(LinLin.kr(Pitch.kr(full[0]), 0, 3000, 0.1, 0.5), 0.05);

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

	Out.ar(100, p1 * amp);
	Out.ar(102, p2 * amp);
	Out.ar(104, p3 * amp);
	Out.ar(106, p4 * amp);
}).add;

//---------------------

/**
* No.5 - CombFilter
*
* Standard Comb Filter
* -gives specific resonanct
* -frequency to input
* -signal
*/
SynthDef(\CombFilter,{ |frequency = 30, resonance = 1, octaves = 10, lagTime = 3|
	var in, delay, delayTime, comb;
	in = In.ar(10, 2);
	delayTime = Lag.kr(1/frequency, lagTime);
	delay = CombC.ar(in, delaytime:delayTime, decaytime:resonance) * 0.4;
	// delay = LPF.ar(delay, frequency * octaves * 10);
	comb = in + delay;
	// comb = HPF.ar(comb, frequency * 4);
	Out.ar(20, comb * 0.5);
}).load(s);

//---------------------

/**
* No.6 - DirectOut
*
* ->Input straight to output
*/

SynthDef(\DirectOut,{
	var in;
	in=In.ar(110,2);
	Out.ar(100,in)
}).load(s);
