SqrOsc s => dac; int melody[8]; // initialize an array
for(0 => int j; j<4; j++){ 
    Math.random2(36,103) => melody[0]; // set the first note
    for(1 => int i; i<melody.cap(); i++) {
        Math.random2(-7,7) => int offset; // maximum offset is half octave
        melody[i-1]+offset => melody[i]; } // set the next note
    for(0 => int i; i<melody.cap() * 4; i++) {
        Std.mtof(melody[i%8]) => s.freq; // convert midi note to frequency
        0.2::second => now; 
}}