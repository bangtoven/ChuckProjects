SinOsc kick => ADSR e => JCRev r => Delay d => dac;
d => Gain g3 => d; 1::ms => d.delay; 0.9 => g3.gain; // put Delay to make feedback
e.set(1::ms, 75::ms, 0.4, 10::ms); // set envelop with short attack
37 => kick.freq; 0.05 => r.mix; // set frequency, dry/wet
for (1 => int delay; delay < 100; delay++) {    
    delay::ms => d.delay; // increase the delay
    for (0 => int count; count<4; count++) { // repleat 4 notes
        e.keyOn(); 50::ms => now;
        e.keyOff(); 50::ms => now;
}}