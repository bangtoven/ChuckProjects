// Jungho Bang
// 2017.11.2.
// PAT 562 Assignment #4
// Modelling a ball using FMIndexSynth

public class BallWithIndexFM extends Chubgraph {	
	FMIndexSynth fm => outlet;
	
	float elasticity;
	float index;
	fun void setParameters(float r, float i, float ela){ 
    	r => fm.ratio;
    	i => index => fm.index;
    	ela => elasticity;
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

    // pass height and how bouncy it is. 
    fun void droppedFrom(float h, float freq) {
    	freq => fm.freq;
	    // a bit of physics
		9.8 => float g;
		g * h => float energy; // m g h

		// h = 0.5 * g t^2
		// g h = 0.5 v^2
		while (energy > 0.001) {
	        Math.sqrt(energy/g * 2 /g) => float t; // calculate time to take to fall
	        t::second => now;

		    energy*0.05 + 0.1 => float amp;
		    energy * elasticity => energy; // determines how much energy remains.
		    Math.sqrt(energy/g * 2 /g) => t; // new time from updated energy

		    t::second => dur length;
		    spork ~ updateIndex(length);
		    fm.setADSR(.05*length, .05*length, 0.5, .1*length);
		    fm.keyOnFor(length);
		}
	}

	fun void bounce(float amp, float freq) {
		freq => fm.freq;
		spork ~ updateIndex(0.5::second);

		0.5::second => dur length;
	    spork ~ updateIndex(length);
	    fm.setADSR(.05*length, .05*length, amp, .1*length);
	    fm.keyOnFor(length);
	}

	fun void play(float amp, float freq, dur duration) {
		freq => fm.freq;
		fm.setADSR(.0::ms, .0::ms, amp, .0::ms);
		fm.keyOnFor(duration);
	}

	fun void playToDacDirectly(float amp, float freq, float pan) {
		fm => ReverbPan rp => dac;
		rp.pan(pan);
		bounce(amp, freq);
		fm =< rp =< dac;
	}
}
