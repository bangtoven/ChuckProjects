// Jungho Bang
// 2017.10.17.
// PAT 562 Assignment #3
// Formant voice model with resonant filters

// Credit
// Listing 7.16 Building a simple formant (resonant filter) voice model
// Simple singing voice model
// by Enrico C., August 1921

// Data from
// Acoustics of Vowels - UCL Phonetics and Linguistics
// http://www.phon.ucl.ac.uk/courses/spsci/acoustics/

public class FormantFilter extends Chubgraph {	
	inlet => ResonZ formant1 => outlet; // (1) inlet through formant filter
	inlet => ResonZ formant2 => outlet; // (2) 2nd formant (vocal tract resonance)
	inlet => ResonZ formant3 => outlet; // (3) 3rd formant

	// Set up filter resonance amounts
	20 => formant1.Q => formant2.Q => formant3.Q; // (5) Sets resonance of all three formant filters

	[	[280,2620,3380], 	// i:
		[360,2220,2960], 	// i
		[560,1480,2520],	// 3:
		[600,2060,2840],	// e
		[800,1760,2500],	// ae
		[760,1320,2500],	// ^
		[740,1180,2640],	// a:
		[560,920,2560],		// a
		[480,760,2620],		// o
		[380,940,2300],		// u
		[320,920,2200]		// u:
	] @=> int formants[][];
	
	["i:","i","3:","e","ae","^","a:","a","o","u","u:"] @=> string pronounce[];

	// --------------- END Initialization

	fun void sayFormant(int i) {
		<<<"FormantFilter is saying",pronounce[i]>>>;
		formants[i][0] => formant1.freq;
		formants[i][1] => formant2.freq;
		formants[i][2] => formant3.freq;
	}
}

// Noise n => FormantFilter f => dac;

// for (int j; j<11; j++) {
// 	f.playFormant(j);
// 	1::second => now;
// }
