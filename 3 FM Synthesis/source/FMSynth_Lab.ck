// Jungho Bang
// 2017.10.24.
// PAT 562 Assignment #4
// FM Synthesis as Chubgraph

public class FMSynth extends Chubgraph {	
	/*
	Jungho's new implementation
	1. outlet instead of dac to extend Chubgraph
	2. control mod gain directly without envelope
	3. call key on/off directly from caller
	*/ 
	SinOsc m => SinOsc c => ADSR adsr => outlet; // SinOsc m => Envelope envm => SinOsc c => ADSR envc => dac; 
	2 => c.sync;

	0::ms => dur INSTANTLY;

	fun void setModFreq(float target, dur duration) {
		if (duration > 0::samp) { // then gradually update, otherwise instantly set it.
			m.freq() => float current;
	    	(target - current) / 100. => float stepSize; // change in each step
	    	duration / 100. => dur stepDuration; // length of each step
		    for(int i; i<100; i++) {
		        m.freq() + stepSize => m.freq;
		        stepDuration => now;
		    }
		}
		target => m.freq; // finally, set it to target.
	}

	fun void setModGain(float target, dur duration) {
		if (duration > 0::samp) { // then gradually update, otherwise instantly set it.
			m.gain() => float current;
	    	(target - current) / 100. => float stepSize; // change in each step
	    	duration / 100. => dur stepDuration; // length of each step
		    for(int i; i<100; i++) {
		        m.gain() + stepSize => m.gain;
		        stepDuration => now;
		    }
		}
	    target => m.gain; // finally, set it to target.
	}

	fun void setCarrierFreq(float target, dur duration) {
		if (duration > 0::samp) { // then gradually update, otherwise instantly set it.
			c.freq() => float current;
	    	(target - current) / 100. => float stepSize; // change in each step
	    	duration / 100. => dur stepDuration; // length of each step
		    for(int i; i<100; i++) {
		        c.freq() + stepSize => c.freq;
		        stepDuration => now;
		    }
		}
		target => c.freq; // finally, set it to target.
	}

	// set ADSR once and use it later.
	fun void set(dur A, dur D, float S, dur R) { 
		adsr.set(A,D,S,R);
	}

	// helper function to enable "100 => fm.freq;" syntax
	fun void freq(float cfreq) { setCarrierFreq(cfreq, INSTANTLY); }
	fun void modFreq(float mfreq) { setModFreq(mfreq, INSTANTLY); }

	// control key on/off directly
	fun void keyOn() { adsr.keyOn(); }
	fun void keyOff() { adsr.keyOff(); }

	fun void keyOnFor(dur length) {
		adsr.releaseTime() => dur R;
		this.keyOn();
		length-R => now;
		this.keyOff();
		R => now;
	}

	fun void playNote(int midi, dur length) {
		midi => Std.mtof => this.freq;
		this.keyOnFor(length);
	}

	// backward compatibility. support the old function with new implementation.
	fun void playFM(float mfreq, float cfreq, float mgain, dur length, float mPeakPoint, float cADSR[]){
		// cfreq => c.freq;
		// mfreq => m.freq;
		cfreq => this.freq;
		mfreq => this.modFreq;

		// set the ADSR values here.
		length * cADSR[0] => dur A;
		length * cADSR[1] => dur D;
		cADSR[2] => float S;
		length * cADSR[3] => dur R;
		this.set(A, D, S, R);

		// spork ~ playadsr(length, cADSR);
		// instead of playadsr, it uses own keyOn/keyOff methods.
		spork ~ keyOnFor(length);
		
		// spork ~ playEnvm( mgain, length, mPeakPoint ); 
		// instead of playEnvm, it directly change the gain with setModGain method.
		length*mPeakPoint => dur mPeakPointDur;
		setModGain(0, INSTANTLY);
		setModGain(mgain, mPeakPointDur);
		setModGain(0, mPeakPointDur);
		length - 2*mPeakPointDur => now;	
	}

	// --- original code
	
	// fun void playEnvm(float mgain, dur length, float mPeakPoint) {
	// 	length * mPeakPoint => dur mPeakPointDur;
	// 	envm.target(mgain);
	// 	envm.duration(mPeakPointDur);
	// 	envm.keyOn();
	// 	mPeakPointDur => now;
	// 	envm.keyOff();
	// 	length - mPeakPointDur => now;
	// }

	// fun void playadsr(dur length, float cADSR[]) {
	// 	length * cADSR[0] => dur A;
	// 	length * cADSR[1] => dur D;
	// 	cADSR[2] => float S;
	// 	length * cADSR[3] => dur R;
	// 	envc.set(A,D,S,R);
	// 	envc.keyOn();
	// 	length-envc.releaseTime() => now;
	// 	envc.keyOff();
	// 	envc.releaseTime() => now;
	// }
}
