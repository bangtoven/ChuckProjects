// Jungho Bang
// 2017.11.1.
// PAT 562 Assignment #4
// Modelling a dropped bouncing ball 

public class Ball extends Chubgraph {	
	FMSynth fm => outlet;

	float mfreq, cfreq, mgain; // to determine FM timbre and physical characteristics
	float elasticity;
    fun void setParameters(float mf, float cf, float mg, float ela){ 
    	mf => mfreq;
    	cf => cfreq;
    	mg => mgain;
    	ela => elasticity;
    }

    // pass height and how bouncy it is. 
    fun void droppedFrom(float h) {
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
		    fm.playFM(mfreq, cfreq, mgain, t::second, .5, [.05, .05, amp, .1]);
		}
	}

	// play single sound
	fun void bounce(float amp) {
		fm.playFM(mfreq, cfreq, mgain, 0.5::second, .5, [.05, .05, amp, .1]);
	}

	// instead of using outlet, it plays the sound directly to the dac
	fun void playToDacDirectly(float h, float pan) {
		fm => ReverbPan rp;
		dac => rp.output;
		0.1 => rp.revMix;
		rp.pan(pan);
		droppedFrom(h);
		fm =< rp;
	}
}
