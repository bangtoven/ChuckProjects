// Jungho Bang
// 2017.11.11.
// PAT 562 Presentation
// Auto-tune

// Credit: Spencer Salazar, https://github.com/ccrma/chugins/ 

public class JHAutoTune extends Chubgraph {	
	// to control turn on/off the effect
	0 => int _activated;
	fun void active(int a) {
		a => _activated;
		if (a == 1) spork ~ _perform();
		// else 		1 => ps.shift;
	}

	int mode; // auto-tune mode
	/*  
		0: just quantizing to nearest semitone
		1: find closest among given list of pitches
		2: use given frequency (interactive)
		3: use given shift value
	 */
	int keys[]; // allowed keys for mode=1
	float freq; // used when mode=2
	1 => float shift;
	
	// ***** Auto-tune *****
	// Pitch tracking
	inlet => PitchTrack pt => blackhole;
	512 => pt.frame;
	4 => pt.overlap;

	// Pitch shift
	inlet => Delay del => PitShift ps => outlet;
	pt.frame()::samp => del.delay; // wait for the pitch tracking?
	1 => ps.mix;
	1 => ps.shift;

	fun void _perform() {
		while(_activated == 1) {
			samp => now;
			if (mode == 3) {
				shift => ps.shift; // just pitch shifting
				continue;
			}

			pt.get() => float pitch; // get current pitch
			if (pitch <= 0)  // if not tracked
				continue; // pass this iteration
			
			pitch => float target;
			if (mode == 0) { // just quantizing to nearest key
				pitch => Std.ftom => Math.round => Std.ftoi => Std.mtof => target; // ftom -> mtof and rounding
			} else if (mode == 1) { // find closest among given list of keys
				closest(pitch) => target;
			} else if (mode == 2) { // use given frequency (interactive)
				freq => target;
			}
			target / pitch => ps.shift; // perform autotune
		}
	}

	fun float closest (float testval) {
	    keys.size() => int len;
	    
	    int octave;
	    Std.ftom(testval) => float testmidi;
	    while (testmidi - (keys[len-1] + octave) > 12) {
	        12 +=> octave;
	    }
	    
	    48000.0 => float lowdiff;
	    int closest_index;
	    int closest_octave;
	    
	    for (int i; i<len; i++) {
	        Std.mtof(octave + keys[i]) => float listnote;
	        Math.fabs(listnote - testval) => float diff;
	        if (diff < lowdiff) {
	            i => closest_index;
	            diff => lowdiff;
	            octave => closest_octave;
	        }
	    }
	    
	    for (int i; i<len; i++) {
	        Std.mtof(octave + 12 + keys[i]) => float listnote;
	        Math.fabs(listnote - testval) => float diff;
	        if (diff < lowdiff) {
	            i => closest_index;
	            diff => lowdiff;
	            octave + 12 => closest_octave;
	        }
	    }
	    
	    return Std.mtof(closest_octave + keys[closest_index]);
    }
}

// adc => JHAutoTune autotune => dac;

// // mode 0
// 0 => autotune.mode; // just quantizing to nearest semitone
// 1 => autotune.active; // start autotune
// 5::second => now;

// // mode 1
// [1, 3, 6, 8, 10] @=> autotune.keys;
// 1 => autotune.mode; // find closest among given list of pitches
// 5::second => now;

// // mode 3
// 0.5 => autotune.shift; // one octave lower
// 3 => autotune.mode; // use given shift value
// 5::second => now;

// // mode 2
// 1 => autotune.mode; // use given frequency (interactive)
// [0, 2, 4, 7, 9, 7, 4, 2, 0, 2, 0] @=> int notes[];
// for (int i; i<60; i++) {
// 	i % notes.size() => int index;
// 	notes[index] + 50 => int note;
// 	note => Std.mtof => autotune.freq;
// 	0.5::second => now;
// }
// 1::second => now;
