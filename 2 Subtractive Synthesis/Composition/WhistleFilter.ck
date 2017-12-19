// Jungho Bang
// 2017.10.18.
// PAT 562 Assignment #3
// Whistle effect with narrow ResonZ filters

public class WhistleFilter extends Chubgraph {	
	inlet => ResonZ r1 => ResonZ r2 => outlet;
	10 => r1.Q; // wide range
	50 => r2.Q; // narrow range
	
	setGain(1);

	// --------------- END Initialization
	
	// change the gain of ResonZ filters
	fun void setGain(float g) {
		g*2 => r1.gain;
		g*3 => r2.gain;
	}

	// set frequency for the filters. frequency for whislte sound
	fun void setFrequency(float targetFreq, int gliding) {
		<<<"whistle:", targetFreq>>>;
		if (gliding) { // if gliding flag is on, gradually change the freq in 250ms
			(targetFreq - r1.freq()) / 50. => float stepSize;
			for(int i; i<50; i++) {
				r1.freq() + stepSize => r1.freq => r2.freq;
				5::ms => now;
			}
		} 
		
		targetFreq => r1.freq => r2.freq; // finally, set it to target
	}
	
}

// Noise n => WhistleFilter w => dac;
// w.setFrequency(400, 1);
// 2::second => now;

// n => WhistleFilter w2 => dac;
// w2.setFrequency(600, 1);
// 2::second => now;

// n => WhistleFilter w3 => dac;
// w3.setFrequency(800, 1);
// 5::second => now;
