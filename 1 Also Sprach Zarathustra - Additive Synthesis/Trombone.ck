// Jungho Bang
// 2017.09.30.
// PAT 562 Assignment #2
// Synthesize Trombone by applying additive synthesis with harmonic series

public class JHTrombone extends Chubgraph {
    [1,4,5,10,11,15,9,9,8,4,4,3,3,2,2,2,2,1,1,1] @=> static int amp[]; // Get this value from MAESTRO project

    Envelope envelope => outlet; // envelope for vibrato
    
    // initialize
    SinOsc oscs[amp.cap()];
    for(int i; i<amp.cap(); i++) {
        SinOsc x @=> oscs[i];
        amp[i]/20. => x.gain; // set amplitude of partial with the amp array.
    }
    
    fun void play(int freq, dur duration) {
        for(int i; i<oscs.cap(); i++) {
            freq*(i+1) => oscs[i].freq; // set frequency
            oscs[i] => envelope; // chuck to envelope
        }
        
        // attack
        envelope.target(1.0);
        envelope.duration(100::ms);
        100::ms => now;
        
        // sustain with tremolo
        TriOsc lfo => blackhole;
        lfo.freq(7); // tremolo frequency
        lfo.gain(0.1);
        now+duration-200::ms => time over; // sustain = duration - (attack+release)
        while (now < over) {
            0.8 + lfo.last() => envelope.target;
            1::samp => now;
        }
        
        // release
        envelope.target(0.0);
        envelope.duration(100::ms);
        100::ms => now;
        
        for(int i; i<oscs.cap(); i++) {
            oscs[i] =< envelope; // unchuck from envelope
        }
    }
}
