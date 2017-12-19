100 => int base;
for(0 => int j; j<4; j++) // repeat 4 times
    for(1 => int i; i<=10; i++) {
        SinOsc s => ADSR e => DelayA d => Pan2 p => dac; // put panning in the end.
        d => Gain feedback => d; 0.9 => feedback.gain; d.delay(200::ms); // simple echo
        e.set(100::ms, 25::ms, 0.5, 500::ms);
        base*i => s.freq; // set frequency to overtone
        -1+i/5.0 => p.pan; // set the position of panning with index
        e.keyOn(); 200::ms => now; e.keyOff(); 500::ms => now; // play the note
    }