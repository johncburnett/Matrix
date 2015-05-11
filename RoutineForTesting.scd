//***for testing purposes only***\\
//only use for running this outside of master.scd

(
SynthDef(\output, {
    Out.ar(0,
		In.ar(10))
}).add;

SynthDef(\help_notRand, {
	arg freq = 500, gate=0;
    Out.ar(10,
		        SinOsc.ar(freq, 0, 0.2) * EnvGen.ar(Env.new([0,1,0],[0.001,0.25]),gate))
}).add;
)
~output = Synth(\output);
~audioInput=Synth.before(~output,\help_notRand);

//***end test code***\\



//***startOfCode_forMaster.scd***\\

//make sure these are actually the names of the generators...
~generatorList = [~audioInput,~droplet,~butter,~patternPerc, ~johnSnare,~phaseMod]

//this variable can be changed live ***THIS IS WHAT THE MATRIX SHOULD CHANGE***
~whichSynth = 0;//choose which synth you want to trig with the routine

//routine
~genRoutine = Routine{
	inf.do{
	~generatorList.at(~whichSynth).set(\gate, 1);
	0.5.wait;
	~generatorList.at(~whichSynth).set(\gate, 0);
	0.5.wait;
	}
};

//play routine
~genRoutine.reset;~genRoutine.play;
