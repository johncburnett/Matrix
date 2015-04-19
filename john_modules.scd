/**
* CombShift
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


/*
* OctoReverb
*
* 8-channel multi-band reverb
*/
SynthDef("OctoReverb",{ |amp = 0.0|
	var in, predelay, reverb;

	var full, low, lowmid, highmid, high;
	full = In.ar(50)!2;
	low = In.ar(51)!2;
	lowmid = In.ar(52)!2;
	highmid = In.ar(53)!2;
	high = In.ar(54)!2;

	in = [low, lowmid, highmid, high];
	predelay = DelayN.ar(in, 0.1, [0.044, 0.048, 0.052, 0.526]);
	reverb = Mix.ar(Array.fill(7,{ CombL.ar(predelay, 0.05, rrand(0.03, 0.05), 15) }));
	6.do({ reverb = AllpassN.ar(reverb, 0.050, rrand(0.03, 0.05), 1) });

	Out.ar(100, reverb * amp);
}).load(s);
