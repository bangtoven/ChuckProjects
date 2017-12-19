// Jungho Bang
// 2017.11.1.
// PAT 562 Assignment #4
// FM Synthesis with index to have consistent timbre, as we did during the class

public class FMIndexSynth extends Chubgraph {	
	SinOsc m => SinOsc c => ADSR adsr => outlet;
	2 => c.sync;

	// use cm-ratio and index
	float _ratio;
	float _index;

	// setting carrier frequency.
	fun void freq(float cFreq) { 
		cFreq => c.freq;
		updateModulator();
	}

	// mFreq and mGain are updated with ratio and index.
	fun void updateModulator() {
		c.freq() * _ratio => m.freq; // set mod freq
		m.freq() * _index => m.gain; // set mod gain: delta
	}

	fun void ratio(float r) { 
		r => _ratio; 
		updateModulator();
	}
	
	fun void index(float i) { 
		i => _index; 
		updateModulator();
	}

	// set ADSR once and use it later.
	fun void setADSR(dur A, dur D, float S, dur R) { 
		adsr.set(A,D,S,R);
	}

	// control key on/off directly
	fun void keyOn() { 
		<<<c.freq(), m.freq(), m.gain()>>>;
		adsr.keyOn(); 
	}
	fun void keyOff() { adsr.keyOff(); }

	fun void keyOnFor(dur length) {
		adsr.releaseTime() => dur R;
		this.keyOn();
		length-R/2 => now;
		this.keyOff();
		R/2 => now;
	}

	fun void playNote(int midi, dur length) {
		midi => Std.mtof => this.freq;
		if (length > adsr.releaseTime()) {
			this.keyOnFor(length);
		}
	}

	fun void setCarrierFreq(float target, dur duration) {
		if (duration > 0::samp) { // then gradually update, otherwise instantly set it.
			c.freq() => float current;
	    	(target - current) / 100. => float stepSize; // change in each step
	    	duration / 100. => dur stepDuration; // length of each step
		    for(int i; i<100; i++) {
		        c.freq() + stepSize => this.freq;
		        stepDuration => now;
		    }
		}
		target => this.freq; // finally, set it to target.
	}

	fun void playNoteGlide(int midi, dur length, dur glideLength) {
		midi => Std.mtof => float targetFreq;
		spork ~ this.setCarrierFreq(targetFreq, glideLength);
		this.keyOnFor(length);
	}
}

// FMIndexSynth fm => dac;
// fm.setADSR( 2::ms, 171::ms, 0.80, 35::ms );  //a, d, s, r
// 0.8 => fm.ratio;
// 3 => fm.index;

// fm.playNote(60, 0.5::second);
// fm.playNote(62, 0.5::second);
// fm.playNote(64, 0.5::second);
// fm.playNote(67, 0.5::second);
// fm.playNote(69, 0.5::second);
// fm.playNote(67, 0.5::second);
// fm.playNote(64, 0.5::second);
// fm.playNote(62, 0.5::second);
// fm.playNote(60, 0.5::second);
