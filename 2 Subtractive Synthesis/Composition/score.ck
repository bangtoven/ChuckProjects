// Jungho Bang
// 2017.10.17.
// PAT 562 Assignment #3
// Score file to generate white noise from the voices and control the filters

// Change gain of two UGens simulatnaeously
fun void crossFade(UGen out, UGen in, dur duration) {
    spork ~ fade(out, 0, duration);
    spork ~ fade(in, 1, duration);
    duration => now;
}

// Change gain of UGen in 100 steps
fun void fade(UGen u, float targetGain, dur duration) {
    u.gain() => float currentGain;
    (targetGain - currentGain) / 100. => float stepSize; // change in each step
    duration / 100. => dur stepDuration; // length of each step

    for(int i; i<100; i++) {
        u.gain() + stepSize => u.gain;
        stepDuration => now;
    }
    targetGain => u.gain; // finally, set it to target for safety.
}

// Credit: rhodey.ck in examples
fun float randomPentatonic(int base, int octave) {
    [ 0, 2, 4, 7, 9 ] @=> int scale[];

    scale[Math.random2(0,scale.cap()-1)] => int note;
    Std.mtof( ( base + Math.random2(0,octave) * 12 + note ) ) => float freq;

    return freq;
}

fun dur randomRhythm(dur whole) {
    Math.random2(0,8) => int r;
    if (r < 5) 
        return whole / 4; // 62.5% - quarter
    else if (r < 7)
        return whole / 2; // 25% - half
    else
        return whole; // 12.5% - whole
}

// ------------- END Function definition

// dac => WvOut out => blackhole;
// me.sourceDir() + "/Subtractive synthesis is.wav" => string _capture; 
// _capture => out.wavFilename;

<<<"\n--- PART 1 Noise making">>>;

// It makes noise with voices.
<<<"What is Subtractive Synthesis?">>>;
Voices v1 => Gain voices => Gain myNoise => Gain direct => dac; // Start with one 'Voices' Ugen
v1.shuffleVoices();
v1.playOneAtATime(1::second);
<<<"Activate all of them from random position">>>;
v1.toRandomPosition();
v1.addOneByOne(0.4::second, 0);
<<<"Change speed gradually">>>;
v1.setRandomSpeed(0.3, 1.5, 1);
2::second => now;

<<<"Add more voices">>>;
Voices v2 => HPF vhpf2 => voices;  // Initialize new voices
Voices v3 => HPF vhpf3 => voices; // Put HPF on them to emphasize high freq part
0 => v2.gain => v3.gain; // start from 0 gain
5000 => vhpf2.freq; // set hpf parameters
10000 => vhpf3.freq;
2 => vhpf2.gain;
5 => vhpf3.gain;
v2.toRandomPosition();
v3.toRandomPosition();
v2.setRandomSpeed(1.5, 3.0, 1); // faster playback rate
v3.setRandomSpeed(3.0, 5.0, 1);
// v2.setRandomSpeed(1.5, 3.0, 0); // faster playback rate
// v3.setRandomSpeed(3.0, 5.0, 0);
spork ~ fade(v2, 1.0, 2::second); // gradually increase the gain
spork ~ fade(v3, 1.0, 2::second);

// Boost high frequency
voices => HPF vhpf => myNoise; // to emphasize high freq part
0 => vhpf.gain;
600 => vhpf.freq;
fade(vhpf, 2, 2::second); // gradually increase the gain

<<<"They become whitenoise-like sound">>>;
3::second => now;


// <<<"\n--- PART 2 Ocean Wave">>>;

// <<<"Simulate Ocean Wave">>>; // using code of Ex1
// myNoise => ResonZ oceanWave => Gain oceanWaveMix => dac;
// 2 => oceanWave.Q;
// 0.0 => float t;
// 1600 => oceanWave.freq;

// crossFade(direct, oceanWaveMix, 4::second); // Cross fade
// direct =< dac; // Then unchuck the previous one.
// <<<"ResonZ filter ready">>>;

// now + 4::second => time oceanWaveEnd;
// while (now < oceanWaveEnd) {
//     100. + (1+Math.sin(t))/2 * 3000. => oceanWave.freq;
//     t+.005 => t;
//     5::ms => now;
// }

// <<<"Ocean Wave Ended">>>;


<<<"\n--- PART 2 Average Filter">>>;
<<<"Try my AverageFilter with delayed inputs">>>;
myNoise => AverageFilter af => NRev afMixReverb => dac;
af.setFrequency(1000);
0 => afMixReverb.gain; // start from zero to fade in
0.05 => afMixReverb.mix; // Add some reverb on it
crossFade(direct, afMixReverb, 4::second); // swap the sound/filter by crossfading
direct =< dac; // unchuck unnecessary sound source

<<<"My AverageFilter can play little melody">>>;
for(int i; i<8; i++) {
    randomPentatonic(72, 1) => float freq; // randomly choose a pentatonic frequency
    af.setFrequency(freq);
    randomRhythm(2.0::second) => now; // randomly choose rhythm among whole, half and quarter
}


<<<"\n--- PART 3 Whistle Filter">>>;
<<<"Make whistle sound from noise">>>;
myNoise => WhistleFilter wf1 => Gain whistleMix => dac;
0 => whistleMix.gain;
crossFade(afMixReverb, whistleMix, 4::second);
afMixReverb =< dac;

<<<"Whistling">>>;
for(int i; i<8; i++) {
    randomPentatonic(48, 1) => float freq;
    wf1.setFrequency(freq, 1); // Always change frequency by gliding
    randomRhythm(2.0::second) => now;
}

<<<"Let's make more whistles">>>;
fun void playWhistle(WhistleFilter wf, dur duration) {
    now + duration => time end;
    while (now < end) {
        randomPentatonic(48, 1) => float freq;
        wf.setFrequency(freq, Math.random2(0,1)); // randomize whether to glide frequency change
        randomRhythm(2.0::second) => now;
    }
}
myNoise => WhistleFilter wf2 => whistleMix;
myNoise => WhistleFilter wf3 => whistleMix;

8::second => dur wfDuration;
spork ~ playWhistle(wf1, wfDuration); // play three whistles together by sporking
spork ~ playWhistle(wf2, wfDuration);
spork ~ playWhistle(wf3, wfDuration);
wfDuration => now;

3::second => now;

<<<"\n--- PART 4 Comb Filter">>>; // Skipping FeedforwardCombFilter
<<<"Comb filter has unique timbre and harmonic">>>;
// myNoise => FeedforwardCombFilter fowardCF => Gain combMix => dac;
myNoise => FeedbackCombFilter backCF => Gain combMix => dac; // two types of comb filter
0.8 => backCF.gain;
0 => combMix.gain;
crossFade(whistleMix, combMix, 4::second);
whistleMix =< dac;

<<<"Feedforward CombFilter is quite subtle.">>>;
// for(int i; i<8; i++) {
//     randomPentatonic(60, 2) => float freq;
//     fowardCF.setFrequency(freq); 
//     randomRhythm(2.0::second) => now;
// }

<<<"Feedback CombFilter is much harsher.">>>;
// // Cross fade into 
// spork ~ fade(fowardCF, 0, 4::second);
// spork ~ fade(backCF, 0.8, 4::second); // crossfade while playing the same note
// for(int i; i<8; i++) {
//     randomPentatonic(48, 2) => float freq;
//     fowardCF.setFrequency(freq*2);  // feed-forward 
//     backCF.setFrequency(freq);    // feed-back
//     randomRhythm(2.0::second) => now;
// }

<<<"The bigger the feedback ratio, the harsher the sound">>>;
// fowardCF =< combMix;
backCF.setFeedback(0.75);
for(int i; i<8; i++) {
    backCF.setFeedback(0.75 + 0.01*i); // increase the feedback ratio

    randomPentatonic(48, 2) => float freq;
    backCF.setFrequency(freq);   
    randomRhythm(2.0::second) => now;
}

backCF.setFrequency(200);
// fade(fowardCF, 0.0, 0.1::second);
// fade(backCF, 0.8, 0.1::second);
backCF.setFeedback(0.91);



<<<"\n--- PART 5 Formant Filter">>>;

<<<"Add formant filter to simulate human vowel sound">>>;
backCF => FormantFilter ff => Gain singMix => dac;
2 => ff.gain;
ff.sayFormant(6); // ahh sound
0 => singMix.gain;
crossFade(combMix, singMix, 4::second);
combMix =< dac;

<<<"Speak vowels it can simulate">>>;
for(int i; i<11; i++) {
    ff.sayFormant(i); // to set which vowel to play
    0.4::second => now;
}


<<<"\n--- PART 6 Singing with simulated vowels">>>;
// Control both Feedback filter and Formant filter
fun void singWithVowel(FeedbackCombFilter comb, FormantFilter singer, dur duration) {
    now + duration => time end;
    while (now < end) {
        randomPentatonic(48, 1) => float freq;
        backCF.setFrequency(freq);  // set folds frequency
        Math.random2( 0, 10 ) => int formant; // randomly choose a vowel
        ff.sayFormant(formant);
        randomRhythm(2.0::second) => now;
    }
}
singWithVowel(backCF, ff, 8::second);

<<<"Play whistle together">>>;
myNoise => WhistleFilter wfSing => singMix;
0 => wfSing.gain;
fade(wfSing, 1.5, 2::second);

10::second => dur singDuration;
spork ~ singWithVowel(backCF, ff, singDuration); // singing along with
spork ~ playWhistle(wfSing, singDuration);       // whistling   
singDuration => now;


<<<"\n--- PART 7 Going back to noise">>>;
Voices lastVoice => dac;
lastVoice.toRandomPosition();
0 => lastVoice.gain;
crossFade(singMix, lastVoice, 4::second); // leave only a Voices Ugen
singMix =< dac;

<<<"Leave only one voice on">>>;
lastVoice.deactivateAllExceptOneVoice(3, 0.4::second, 1); // leave only one voice
5::second => now;

fade(lastVoice, 0, 5::second);

// <<<"Program end at", now/second, "seconds">>>;
// out.closeFile();
