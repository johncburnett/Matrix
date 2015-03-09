(
//Server.killAll;
//USE ONLY IF YOU WOULD LIKE TO OUTPUT TO GO OUT OF "_________" (not default output)
//--OTHERWISE SIMPLY EVALUATE "s.boot" to boot with default audio output
s = Server.new(\beast);
o = s.options;
//o.inDevice = "Soundflower (2ch)";
o.inDevice = "MOTU 4pre";
//o.outDevice = "MOTU 4pre";
//o.inDevice = "Built-in Microph";
o.outDevice = "Built-in Output";
o.memSize = 8192 * 4;
s.boot;
)

//---------------------------------\\
(
//_Input Module
SynthDef(\input, {
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
	Out.ar(50,input);//original signal
	Out.ar(51,band1);//low band
	Out.ar(51,band2);//lowmid
	Out.ar(53,band3);//highmid
	Out.ar(54,band4)//high
}).add;

//_Generic Processing Module
SynthDef(\gen_Process, {
	arg amp = 1.0;
	var full,low,lowmid,highmid,high;
	//
	full = In.ar(50)!2; //all inputs are stereo
	low = In.ar(51)!2;
	lowmid = In.ar(52)!2;
	highmid = In.ar(53)!2;
	high = In.ar(54,2)!2;
	//
	//PROCESS!!
	//
	Out.ar(100,input);
	Out.ar(102,band1);
	Out.ar(104,band2);
	Out.ar(106,band3);
	Out.ar(108,band4);
	Out.ar(110,input);
	Out.ar(112,band1);
	Out.ar(114,band2);
	Out.ar(116,band3);
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
	}
).add;

~input=Synth.head(1,\input);
~output=Synth.tail(1,\output);

)
