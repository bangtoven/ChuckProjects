// Jungho Bang
// 2017.10.01.
// PAT 562 Assignment #2
// Synthesize Cymbal with noise and inharmonic high pitch oscilliators

public class JHCymbal extends Chubgraph {
	// Play pulse of noise and high pitch osc
	Noise n => ADSR env => NRev r => outlet; 
	
	// make inharmonic oscillators
	[137, 317, 537, 737, 937, 1317, 1713, 3713, 13713] @=> int freqArr[];
	for (int i; i<freqArr.cap(); i++) {
		SawOsc saw => env;	
		0.1 => saw.gain;
		freqArr[i] => saw.freq;
	}
	
	// To make timbre, adding FM sound
	SinOsc lfo => SinOsc t => env;
	200 => lfo.gain;
	300 => lfo.freq;
	2 => t.sync; // to apply FM
	5000 => t.freq;
	0.5 => t.gain;

	0.1 => r.mix; // give some reverb

	fun void play(dur duration) {
		env.set(5::ms, 0::ms, 1.0, 500::ms); // short attack, and long release
		env.keyOn();
		200::ms => now;
		env.keyOff();

		duration => now; // to get enough reverb
	}
}

// JHCymbal c => dac;
// c.play(5::second);
