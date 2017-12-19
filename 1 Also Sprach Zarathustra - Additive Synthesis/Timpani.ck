// Jungho Bang
// 2017.09.30.
// PAT 562 Assignment #2
// Synthesize Trumpet with pulse of 4 different oscilliators in inharmonic

public class JHTimpani extends Chubgraph { 
    // Different oscs to make percussive sound
    TriOsc per0 => ADSR envelope;
    SawOsc per1 => envelope;
    SqrOsc per2 => envelope;
    SinOsc per3 => envelope;
    envelope => NRev reverb => LPF filter => outlet;

    // set to different gain value
    0.81 => per0.gain; 
    0.47 => per1.gain;
    0.31 => per2.gain;
    0.17 => per3.gain;

    0.75 => reverb.mix; // reverb to make percussive sound with pulse
    3500 => filter.freq; // low pass filter to make more percussive
    envelope.set(0::ms, 0::ms, 1.0, 20::ms); // short attack time
    20::ms => dur pulseDur; // play a short pulse, but long enough to can hear the freq.

    fun void play(float freq, dur noteDur) {
        // set the phases to zero
        0 => per0.phase;
        0 => per1.phase;
        0 => per2.phase;
        0 => per3.phase;

        // Set to inharmonic frequencies
        freq => per0.freq;
        freq*1.13 => per1.freq;
        freq*1.37 => per2.freq;
        freq*1.73 => per3.freq;
        
        envelope.keyOn();
        pulseDur => now; // play a pulse
        envelope.keyOff();
        (noteDur-pulseDur) => now; // and wait
    }
}
    
