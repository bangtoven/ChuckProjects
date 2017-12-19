// Jungho Bang
// 2017.09.30.
// PAT 562 Assignment #2
// Score file to control the instruments

50 => int baseFreq;

fun int noteFrom(int base, int diff) {
    return Std.ftoi(base * Math.pow(2, diff/12.0));
}

//**
//  Part 1: Diverging Notes. C-C-G-C-E
//**
DivergingNotes d; // Play as pulse first, and then diverge them.
baseFreq => d.baseFreq;
d.initialize();

<<<"Pulse">>>;
for(int t; t<8; t++){
    for(int i; i<5; i++) {
        spork ~ d.playPartial(i, 50::ms, 0::ms);
    }
    500::ms => now;
}

<<<"Diverging">>>;
for(int t; t<16; t++){
    for(int i; i<5; i++) {
        spork ~ d.playPartial(i, 50::ms, 0::ms);
        (t*10)::ms => now;
    }
    (500-t*10*5) => int d;
    if (d > 0) d::ms => now;
    else     100::ms => now;
}

<<<"Separated">>>;
for(int i; i<5; i++) {
    d.playPartial(i, 100::ms, 400::ms);
}
1000::ms => now;

<<<"Main theme">>>;
d.playPartial(1, 600::ms, 400::ms);
d.playPartial(2, 600::ms, 400::ms);
d.playPartial(3, 600::ms, 400::ms);
d.playPartial(4, 1500::ms, 500::ms);
d.changeFreqForPartial(4, -1); // lowering 4th partial(E) by one note
spork ~ d.playPartial(4, 5::second, 0::ms); // makes Zarathustra
1::second => now;

<<<"Fade out the first part">>>;
d.fadeOut(4000); // fade out in 4000 ms
1::second => now;

//**
//  Part 2: Also Sprach Zarathustra Overture
//**

// Define frequencies and durations.
baseFreq / 2 => int C0;
C0 * 2 => int C1;
C0 * 3 => int G1;
C0 * 4 => int C2;
C0 * 5  => int E2;
noteFrom(E2, -1) => int Eb2;

4::second => dur whole;
whole / 2 => dur half;
half / 2 => dur quarter;
quarter / 2 => dur eighth;
quarter / 4 => dur sixteenth;

// Define the instruments to use
Gain mix;
Gain mixLeft => NRev revLeft => dac.left; // each speaker has its own gain, reverb control
Gain mixRight => NRev revRight => dac.right; // reverb will be used only at the end.
mix => mixLeft;
mix => mixRight;
0 => revLeft.mix => revRight.mix;

JHTrombone bass => mix;
JHTrumpet trp => mixLeft; 
JHTrombone trb1 => mix;
JHTrombone trb2 => mixRight; 
JHCymbal cymbal => mix;
JHTimpani tpn => mix;
JHStrings str => Envelope strEnv; // for fade out control
strEnv => mixRight;
strEnv => DelayL delay => mixLeft; // Put delay between left and right speaker to make it sounds from sides
5::ms => delay.delay;
0.7 => strEnv.value;

0.5 => mixLeft.gain => mixRight.gain;

// Define functions to play simultaneously
fun void play2Brass(int freq, dur duration) { // play Brass together by sporking
    spork ~ trb1.play(freq, duration);
    2::ms => now; // give some offset
    spork ~ trp.play(freq*2, duration); // an octave higher
    duration => now;
}
fun void play3Brass(int freq, dur duration) { // This new function plays 3 brass.
    spork ~ trb2.play(freq, duration); 
    spork ~ trb1.play(freq, duration);
    2::ms => now; // give some offset
    spork ~ trp.play(freq*2, duration); // an octave higher
    duration => now;
}
fun void playAllTogether(int note, dur duration) { 
    noteFrom(C2, note) => int freq;
    spork ~ play3Brass(freq, duration); // Brass Plays an octave below 
    spork ~ str.play(freq, 5, duration); 2::ms => now; 
    spork ~ str.play(freq/2, 5, duration); // Add one more string plays an octave below
    duration => now;
}
fun void playPercussionAllTogether() {
    spork ~ cymbal.play(half); 
    spork ~ tpn.play(C1, eighth);
    spork ~ tpn.play(G1, eighth);
}

//**
//  Part 2-0: Play the main theme we found from harmonics
//**
<<<"Play the bottom C0 note">>>;
0.2 => bass.gain;
spork ~ bass.play(C0, whole * 4); // Spork it to play underneath the following melody.
whole => now; 
0.1 => bass.gain;

<<<"Brass playing the overtone theme: C-G-C">>>;
0.5 => trb1.gain;
trb1.play(C1, half);
trb1.play(G1, half);
trb1.play(C2, whole - sixteenth);

<<<"String ensemble playing: E-Eb">>>;
spork ~ trb1.play(E2, sixteenth); 5::ms => now; 
spork ~ str.play(E2, 3, sixteenth); // spork it to play together with brass
sixteenth => now;

<<<"Hit the Cymbal on time">>>;
spork ~ cymbal.play(whole); // spork to play together with following string note
strEnv.target(0.0);
strEnv.duration(2 * whole); // Fade out while playing
0.3 => trb1.gain;
spork ~ str.play(Eb2, 3, whole * 4); 5::ms => now;
spork ~ trb1.play(Eb2, whole); 
whole => now;

<<<"Timpani playing: C-G C-G C-G C-G">>>;
for (int i; i<4; i++) {
    tpn.play(C2, eighth + i*20::ms);
    tpn.play(G1 * 3/4, eighth + i*20::ms); // gradually decrease the tempo
}
quarter => now;
spork ~ tpn.play(C1, eighth); // play with the following Brass

//**
//  Part 2-1: Repeat
//**
<<<"Repeat, but with some change">>>;
<<<"Play the bottom C0 note">>>;
0.2 => bass.gain;
spork ~ bass.play(C0, whole * 4); 

<<<"Add trumpet to Brass: C-G-C">>>; // Add trumpet
trp => mixLeft;
trb1 => mixRight; // put them into different location
0.6 => trp.gain;
0.55 => trb1.gain;
play2Brass(C1, half);
play2Brass(G1, half);
play2Brass(C2, whole - sixteenth);

<<<"String ensemble playing Different melody: Eb-E">>>;
0.75 => strEnv.value;
spork ~ play2Brass(Eb2, sixteenth); 5::ms => now; 
spork ~ str.play(Eb2, 5, sixteenth); // Change the order to make more harsh timbre
sixteenth => now;

spork ~ cymbal.play(whole); // spork to play together with following string note
strEnv.target(0.0);
strEnv.duration(2 * whole); 
0.3 => trb1.gain;
0.3 => trp.gain;
spork ~ str.play(E2, 5, whole * 4); 5::ms => now;
spork ~ play2Brass(E2, whole); 
whole => now;

<<<"Timpani slower than before">>>;
1.1 => tpn.gain;
for (int i; i<4; i++) {
    tpn.play(C2, eighth + i*40::ms);
    tpn.play(G1 * 3/4, eighth + i*40::ms); // gradually decrease the tempo
}
quarter => now;
spork ~ tpn.play(C1, eighth); // play with the following Brass

//**
//  Part 2-2: Finishing
//**
<<<"Last iteration: Bottom C0 note">>>;
0.2 => bass.gain;
spork ~ bass.play(C0, whole * 8); 

<<<"Add one more Trombone to Brass: C-G-C">>>; // Add one more Brass, move trumpet to center
trp => mix;
trb1 => mixRight; // put them into different location
trb2 => mixLeft;
0.65 => trp.gain;
0.6 => trb1.gain => trb2.gain;
play3Brass(C1, half);
play3Brass(G1, half);
play3Brass(C2, whole - sixteenth);

<<<"Climax">>>;
0.7 => strEnv.value;
playAllTogether(4, sixteenth); // E
spork ~ cymbal.play(whole); 
playAllTogether(9, whole); // A

spork ~ cymbal.play(whole); 
playAllTogether(9, eighth); // A
playAllTogether(11, eighth); // B
playAllTogether(12, half); // C
playAllTogether(14, half); // D

<<<"E-F-G / E-C-G">>>;
1.1 => tpn.gain;
for(int i; i<2; i++) { 
    playPercussionAllTogether();

    playAllTogether(16, eighth); // E
    playAllTogether(17, eighth); // F
    if (i != 0 ) break;
    spork ~ playAllTogether(19, whole); // G
    // Brass playing E-C-G along
    quarter => now;
    play3Brass(E2, quarter);
    play3Brass(C2, quarter);
    play3Brass(G1, quarter);
}
playAllTogether(19, whole); // G

<<<"Finishing with polyphony">>>;
// Defining freq of notes
noteFrom(G1, 2) => int A1;
noteFrom(A1, 2) => int B1;
noteFrom(C2, 2) => int D2;
G1 * 2 => int G2; G2 * 2 => int G3;
A1 * 2 => int A2; A2 * 2 => int A3;
B1 * 2 => int B2; B2 * 2 => int B3;
C2 * 2 => int C3; C3 * 2 => int C4;
E2 * 2 => int E3;

// Score in 2D Array
[[A3, B3, G3], // trumpet
 [A2, G2, C3], // trombone
 [C2, D2, E2], // trombone
 [A3, B3, C4], // violoin
 [A2, G2, E2], // cello
 [C2, B1, G1]  // contrabass
] @=> int notes[][];

// Add two more strings
JHStrings cell => mix;
JHStrings cont => mix;
// Adjust gain values
0.9 => strEnv.value;
0.8 => trp.gain;
0.7 => trb1.gain => trb2.gain;
0.75 => cell.gain => cont.gain;
for(int i; i<3; i++) {
    playPercussionAllTogether();
    dur duration;
    if (i != 2) half => duration;
    else        whole*4 => duration;
    spork ~  trp.play(notes[0][i], duration);
    spork ~ trb1.play(notes[1][i], duration);
    spork ~ trb2.play(notes[2][i], duration);
    spork ~  str.play(notes[3][i], 5, duration);
    spork ~ cell.play(notes[4][i], 3, duration);
    spork ~ cont.play(notes[5][i], 3, duration);
    if (i == 2) 
        break;
    duration => now;
}

<<<"Timpani roll">>>;
fun void playTimpaniRoll(){
    for (int i; i<16; i++) {
        spork ~ tpn.play(G1, eighth);
        sixteenth => now;
    }
}
spork ~ playTimpaniRoll();
half => now;

<<<"Decrescendo and Crescendo">>>;
for(int t; t<200; t++) {
    (0.5 - t/1000.) => mixLeft.gain => mixRight.gain;
    10::ms => now;
}

for(int t; t<400; t++) {
    (0.3 + t/800.) => mixLeft.gain => mixRight.gain;
    10::ms => now;
}

<<<"Turn up the reverb">>>;
while (mixLeft.gain() > 0) {
    mixLeft.gain()-0.01 => mixLeft.gain => mixRight.gain;
    revLeft.mix()+0.002 => revLeft.mix => revRight.mix;
    20::ms => now;
}

whole*2 => now;
