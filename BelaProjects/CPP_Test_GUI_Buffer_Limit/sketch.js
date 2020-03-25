/***** Banjo Dashboard GUI *****/


// MAIN APP
var guiSketch = new p5(function( sketch ) {

    let canvas_dimensions = [sketch.windowWidth, sketch.windowHeight];

	let verbose = true; // set true to get console feedback
	let verboseEvery = 30; // print feedback every 30 frames
	let verboseFrameCounter = 0;

	// This must match GUI_BUFFER_LENGTH in render.cpp
	let bufSize = 256;
	
	// This must match GUI_FRAME_RATE in render.cpp
	let frameRate = 30;

    sketch.setup = function() {
        sketch.createCanvas(canvas_dimensions[0], canvas_dimensions[1]);
        //sketch.frameRate(120);
        sketch.frameRate(30);
	
		console.log("Bela Data Buffers on Setup");
		console.log(Bela.data.buffers);

    };

    sketch.draw = function() {
        
        // Draw a white background with opacity
        sketch.background(255, 10);
        
        // Retreive the data being sent from render.cpp
        if(verbose && (verboseFrameCounter % verboseEvery == 0)) {
    		
        }

		verboseFrameCounter += 1;

    };
    
}, 'gui');