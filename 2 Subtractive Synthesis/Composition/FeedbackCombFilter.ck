// Jungho Bang
// 2017.10.18.
// PAT 562 Assignment #3
// Comb filter with feedback loop

public class FeedbackCombFilter extends Chubgraph {	
	inlet => Gain mix => outlet;
	mix => Delay d => mix; // add feedback
	setFeedback(0.80);
	0.75 => mix.gain;

	// --------------- END Initialization

	fun void setFeedback(float g) {
		g => d.gain;
	}

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

// Noise n => FeedbackCombFilter f => LPF l => dac;
// 2000 => l.freq;

// f.setFrequency(400);
// 2::second => now;
// f.setFrequency(600);
// 2::second => now;
// f.setFrequency(800);
// 2::second => now;
