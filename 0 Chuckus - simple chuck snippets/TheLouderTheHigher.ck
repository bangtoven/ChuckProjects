adc => Gain squarer => blackhole; adc => squarer; 3 => squarer.op; // to get the power
SinOsc beep => Delay d => JCRev r => dac; 1 => beep.freq; // put feedback and reverb to chain
d => Gain feedback => d; 0.50 => feedback.gain; 10::ms => d.delay; // set feedback
while (true) {
    squarer.last() => float power; // get the power
    if (power > 0.001) {
        power*1000 + 20 => beep.freq; // set the frequency of the beep. when it plays, it has at least 20 Hz.
    } else 1 => beep.freq; // else, set to inaudible frequency
    10::ms => now;
}