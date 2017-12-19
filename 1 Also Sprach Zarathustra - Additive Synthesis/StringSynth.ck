// Jungho Bang
// 2017.09.28.
// PAT 562 Assignment #2
// Additive synthesis by adding harmonic overtones and 'undertones'

// Originally I called it BellShapedPartials, since the middle partial has the highest gain.
public class JHStrings extends Chubgraph { 
    fun void play(int middleFreq, int order, dur duration) {
        // middleFreq has the largest gain.
        // adding 2*order number of partials -> this will change the timbre
        SawOsc sins[2*order+1];

        SawOsc middle => Gain g => outlet; // put the center osc in the middle
        middle @=> sins[order];
        middleFreq => middle.freq; 

        for (1 => int i; i<order; i++) {
            SawOsc u => g; 
            u @=> sins[order + i]; // Put u on the right.
            middleFreq*i + i => u.freq; // Set freq: overtone of middleFreq and add some offset

            SawOsc d => g;
            d @=> sins[order - i]; // Put d on the left.
            d.freq((middleFreq>>i) - i); // Set freq: middleFreq / 2^i

            order => float fo;
            Math.pow(1 - i/fo, 2) => float amp; // Higher order has lower amplitude.
            amp => u.gain;
            amp => d.gain;
        }

        duration => now;

        // unchuck after playback
        for (int i; i<sins.cap(); i++) {
            sins[i] =< g; 
        }
        g =< outlet;
    }
}
