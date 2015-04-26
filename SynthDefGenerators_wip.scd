//Here are the SynthDef Generators!

(
/*
* No.1 - AudioInput
*
* simple audio input
*/
SynthDef(\AudioInput, {
	arg input, choose=50;
	var outputList;
	input = AudioIn.ar(1).dup;//supposed to be vocals
	//---
	Out.ar(choose,input);//original signal
}).load(s);

/*
* No.2 - Droplet
*
* pitch envelope-based synth
*/
SynthDef(\Droplet, {
	//work in progress\\
	arg freq=3000, dur=0.5, intensity, choose=50;
	var sound,volEnv,pitchEnv;
	pitchEnv=EnvGen.ar(Env.new([0.9,0.7,1,1],[0.06,0.05,0.89]*dur,\exponential),doneAction:2);
	volEnv=EnvGen.ar(Env.new([0,1,0.8,0.0],[0.2,0.05,0.75]*dur));
	sound=SinOsc.ar(freq*pitchEnv,mul:volEnv);
	Out.ar(choose,sound);
}).load(s);

/*
* No.3 - Butter
*
* ~Sawtooth Synth
*/
SynthDef(\Butter,{ |freq = 30, amp = 0.95, dur = 1,choose=50|
	var env, tone;
	env = Env.new([0, 0.8, 0], [dur/16, dur/16 * 15], \lin);
	env = EnvGen.ar(env, doneAction:2);
	tone = SinOsc.ar( freq * (1,3..10) * 0.95, mul:(1/5) ).sum.dup;
	tone = Clip.ar(tone, 0, 0.8);
	tone = HPF.ar(tone, freq*3);
	Out.ar(choose, env * tone);
}).load(s);

/*
* No.4 - PatternPerc
*
* midiControlled polyrhythmic percussion instrument
*/
//not quite sure how to incorporate this instrument easily...

/*
* No.5 - JohnSnare
*
* snare-like instrument by John Burnett
*/
SynthDef(\Snare,{
  arg choose=50
	var env, noise;
	env = Env.new([0, 0.8, 0], [0.005, 0.01], \lin);
	env = EnvGen.ar(env, doneAction:2);
	noise = WhiteNoise.ar(0.95);
	noise = BPF.ar(noise, 1000).dup;
	Out.ar(choose, noise * env);
}).load(s);

/*
* No.6 - TBA
*
* a synthDef to be named (coded) later
*/

)
