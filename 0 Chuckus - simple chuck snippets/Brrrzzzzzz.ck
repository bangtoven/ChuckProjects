Gain g => dac;
0.2 => g.gain; 
440 => int baseFreq; // fundamental frequency for overtones
for(0=>int j; j<5; j++) {
    for(1=>int i;i<100;i++) {
        SinOsc s => g; // generate a new sinusoid
        baseFreq*i => s.freq; // add overtones
        (15+j*5)::ms => now; // on each iteration with j, change the duration.
    }
}