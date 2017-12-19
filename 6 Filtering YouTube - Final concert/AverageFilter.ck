// Jungho Bang
// 2017.10.10.
// PAT 562 Assignment #3
// Moving average filter with N delays to play frequency

public class AverageFilter extends Chubgraph {	
	inlet => Gain mix => HPF hpf => outlet; // HPF to remove the peak at 0 Hz
	256 => int MAX; // maximum # of delay : 256
	Delay ds[MAX]; 
	0 => int activatedCount; // # of delays activated

	for(int i; i < MAX; i++) {
	    Delay d @=> ds[i];
	    inlet => d;
	    (i+1)::samp => d.delay;
	}

	// --------------- END Initialization

	// Calculate how many delays needed to make freq to be a fundamental
	fun int freqToDelayCount(float freq) {
		Math.round(66150. / freq) => Std.ftoi => int count;
		return count;
	}

	fun void setFrequency(float freq)	 {
		freqToDelayCount(freq) => int count;
		if (count > MAX) {
			<<<freq,"Hz needs",count,"delayed inputs">>>;
			MAX => count; // maximum # is MAX
		}

		<<<"- AverageFilter Playing",freq,"with",count,"delayed inputs">>>;

		// deactivate
		for(count => int i; i < activatedCount; i++) { // if count > activated, then it will skip
			ds[i] =< mix; // unchuck from output
		}

		// activate
		for(activatedCount => int i; i < count; i++) {
			ds[i] => mix; // chuck to output
		}

		1.0/Math.sqrt( count ) => mix.gain; // adjust gain. found that square root is what I want.
		44100.0/count => hpf.freq; // filter the first peak at 0 Hz

		count => activatedCount; // update the count
	}

}

// Noise n => AverageFilter a => dac;
// for(int i; i<12; i++) {
// 	60+2*i => Std.mtof => a.setFrequency;
// 	1::second => now;
// 	// a.setFrequency(f);
// }

// dac => WvOut out => blackhole;
// me.sourceDir() + "/AverageFilter.wav" => string _capture; 
// _capture => out.wavFilename;
// 2::second => now;
// out.closeFile();
