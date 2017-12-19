TriOsc c => Gain mix => JCRev r => Pan2 p => dac; // reverb and panning
Noise n => mix; 0.1 => n.gain; // put some noise
800 => int base; 200 => int offset;// base frequency, and range of frequency change
for(offset=>int i; i>-offset; i--) { // variable i decreases from offset to -offset
    base + i => c.freq; // set frequency
    i=>float fi; fi/offset => float ratio; // convert index i to float number for division
    ratio => p.pan; // car is moving from right to left.
    1-Math.fabs(ratio) => mix.gain; // the closer to the base freq, the louder
    30::ms => now;
} 2000::ms => now; // get some reverb