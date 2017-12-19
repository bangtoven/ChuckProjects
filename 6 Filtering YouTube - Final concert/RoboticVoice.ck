// Jungho Bang
// 2017.10.27.
// PAT 562 Assignment #4
// AM based robotic voice filter. (Ge Wang's i-robot patch is added as well.)

public class RoboticVoice extends Chubgraph {	
	inlet => Gain snd => outlet;
	SinOsc osc => blackhole;
	
	// Amplitude modulator
	fun void ampMod(UGen u, float freq) {
		freq => osc.freq;
		// SinOsc mod => osc; // tried FM on Amp modulator
		// 2 => osc.sync;
		// 500 => mod.gain;
		// 100 => mod.freq;
		while(true) {
			osc.last() => u.gain;
			1::samp => now;
		}
	}
	spork ~ ampMod(snd, 100);

	// Credit: Ge Wang. i-robot.ck in examples
	snd => Gain g1 => DelayL d => outlet;
	d => Gain g3 => d; // feedback
	// set parameters
	10::ms => d.delay;
	0.1 => g1.gain;
	0.9 => g3.gain;

	// --------- END Init

	fun void say(string path) {
	//	me.sourceDir() + "narration/" + path + ".WAV" => snd.read;
	//	snd.length() => now;
	}
}
