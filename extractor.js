//this is just something small i threw together for the js object in max to handle spectral data

inlets = 4;
outlets = 1;
var partials = new Array();

function list() {
	if (inlet == 1) {
		//create new
		partials.length = 0;
		var a = arrayfromargs(arguments);
		partials = a;
	}
	
	else {
		//combine
		var b = arrayfromargs(arguments);
		partials = partials.concat(b);
	}
	
}

function bang() {
	if (inlet == 0) {
		//output current partials
		outlet(0, partials);
	}
	
	else if (inlet == 3) {
		//erase and output empty list
		partials.length = 0;
		outlet(0, [0, 0]);
	}
}
