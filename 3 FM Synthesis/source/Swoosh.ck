// Jungho Bang
// 2017.11.1.
// PAT 562 Assignment #4
// Swoosh- Wind sound of fast moving ball

// make wind wound with noise and band pass filter
public class Swoosh extends Chubgraph {
	Noise n => ResonZ bpf => ADSR env => ReverbPan wp; // using my ReverbPan
	0.5 => n.gain;
	dac => wp.output; // due to a bug in chuck, we need this way.
	0.1 => wp.revMix;

	4000 => bpf.freq;
	5 => bpf.Q;

	// Sweeping the frequency
	fun void updateFilterFreq() {
	    for(int i; i<100; i++) {
	        4000 - 20*i => bpf.freq;
	        10::ms => now;
	    }
	}

	// Moving pan
	fun void updatePanning(float from, float to, dur length) {
		// from => wp.pan;
	 //    for(int i; i<100; i++) {
	 //        from + (to-from)*i/100.0 => wp.pan;
	 //        5::ms => now;
	 //    }
	 	wp.move(from, to, length);
	}

	fun void wind(float from, float to, float gain, dur length) {
		gain => env.gain;
	    env.set(100::ms, 0::ms, 1.0, 500::ms);
	    env.keyOn();
	    spork ~ updateFilterFreq();
	    spork ~ updatePanning(from, to, length);
	    0.1::second => now;
	    env.keyOff();
	    2.0::second => now;
	}
}

// wind(-1, 2.0, 1);
// wind(1, -2.0, 1);
// wind(-1, 2.0, 0.5);
// wind(1, -2.0, 0.5);

