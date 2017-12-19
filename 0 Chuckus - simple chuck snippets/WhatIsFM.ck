fun void whatIsFM(int freq, int modFreq, int modGain) {
    SinOsc m => SinOsc s => dac; 2 => s.sync; // two sinusoids chucked
    freq => s.freq; modFreq => m.freq; modGain => m.gain; // set modulator's frequency and gain.
    3::second => now; 0 => s.gain; // play for 3 seconds;
}
for(0=>int i; i<10; i++) { // try 10 different inputs
    Math.random2(20,10000)=>int freq; Math.random2(1,500)=>int modFreq; Math.random2(1,1000)=>int modGain; // get random value
    <<<"Trial",i+1,"::", freq, modFreq, modGain>>>; // print the generated inputs
    whatIsFM(freq, modFreq, modGain); // call the function
}