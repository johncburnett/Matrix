/**
* As of right now, this code generates sets of faders (wih various parameters) that the user can 
* access through the arrays returned by the function. One can then map the value of each slider
* with the .action{} method.
*/

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
	});

	sliderSet;
};

~sliders1 = ~sliderGen.value(400, 300, 0, 0, 5);
~sliders2 = ~sliderGen.value(400, 300, 400, 0, 5);
~sliders3 = ~sliderGen.value(400, 300, 0, 300, 5);
~sliders4 = ~sliderGen.value(400, 300, 400, 300, 5);
)
















