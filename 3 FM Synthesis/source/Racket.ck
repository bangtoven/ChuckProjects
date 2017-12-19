// Jungho Bang
// 2017.11.2.
// PAT 562 Assignment #4
// Modelling a ball using FMIndexSynth

public class Racket extends Chubgraph {	
	FMIndexSynth fm => outlet;

	float index;
	fun void setParameters(float r, float i){ 
    	r => fm.ratio;
    	i => index => fm.index;
    }

    fun void updateIndex(dur duration) {
    	0 => fm.index;
    	for(int i; i<50; i++) {
    		index * i/50.0 => fm.index;
    		duration/100 => now;
    	}
    	for(int i; i<50; i++) {
    		index - index * i/50.0 => fm.index;
    		duration/100 => now;
    	}
    	index => fm.index;
    }

	fun void introduce(float amp, float freq) {
		freq => fm.freq;
		spork ~ updateIndex(0.5::second);

		0.5::second => dur length;
	    spork ~ updateIndex(length);
	    fm.setADSR(.05*length, .05*length, amp, .1*length);
	    fm.keyOnFor(length);
	}

	fun void hit(float amp, float freq, dur duration) {
		freq => fm.freq;
		fm.setADSR(.0::ms, .0::ms, amp, .0::ms);
		fm.keyOnFor(duration);
	}

	fun void falling(float amp, float freq, dur duration) {
		spork ~ hit(amp, freq, duration);
		fm.setCarrierFreq(freq/2.0, duration);
	}

	fun void rising(float amp, float freq, dur duration) {
		spork ~ hit(amp, freq, duration);
		fm.setCarrierFreq(freq*2.0, duration);
	}
}
