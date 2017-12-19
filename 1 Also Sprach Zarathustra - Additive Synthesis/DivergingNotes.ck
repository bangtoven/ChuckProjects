// Jungho Bang
// 2017.09.28.
// PAT 562 Assignment #2
// Generate 5 harmonic partials and play all together or one at each time

public class DivergingNotes {
    int baseFreq;
	SinOsc oscs[5]; // five sine osc to play five partials
	ADSR envs[5]; // each osc has own envelope.
	Gain mix => JCRev reverb => dac; // give some reverb.
	0.01 => reverb.mix;

    fun void initialize(){
        for(int i; i<5; i++) { 
            SinOsc s => ADSR env => mix;
            baseFreq*(i+1) => s.freq; // set freq of sine with multiple of base freq.
            env.set(20::ms, 0::ms, 1.0, 150::ms);
            s @=> oscs[i]; // put into array
            env @=> envs[i];
        }
    } 

	// Function to play a single partial in the array
	fun void playPartial(int index, dur duration, dur release) {
	    0 => oscs[index].phase;
	    envs[index].keyOn();
	    duration => now;
	    envs[index].keyOff();
	    release => now;
	}

	fun void changeFreqForPartial(int i, int note) {
		oscs[i].freq() * Math.pow(2,note/12.0) => oscs[i].freq; // change freq with given note diff.
	}

	fun void fadeOut(int duration) {
		duration => float fd;
		for(int i; i<duration; i++) {
		    mix.gain() - 1/fd => mix.gain; // fade out in 'duration' ms.
    		1::ms => now;
		}
	}
}