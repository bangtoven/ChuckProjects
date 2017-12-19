// Jungho Bang
// 2017.10.18.
// PAT 562 Assignment #3
// Comb filter with delayed input

public class FeedforwardCombFilter extends Chubgraph {	
	inlet => Gain mix => outlet;
	inlet => Delay d => mix; // add delayed input
	
	// --------------- END Initialization

	fun float freqToSampleDelay(float freq) {
		44100. / freq  => float delay; // sample rate divided by freq gives how much delay we need
		<<<freq,"Hz -> delay",delay,"samples">>>;
		return delay;
	}

	fun void setFrequency(float freq) {
		freqToSampleDelay(freq) => float delay;
		delay::samp => d.delay; // set delay 
	}
	
}

// Noise n => FeedforwardCombFilter f => dac;

// f.setFrequency(600);
// 2::second => now;
// f.setFrequency(800);
// 2::second => now;
