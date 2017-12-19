// Jungho Bang
// 2017.10.17.
// PAT 562 Assignment #3
// Generate noise with multiple voices by Apple's built-in Speech Synthesis 

public class Voices extends Chubgraph {	
	// file names for WAV files
	["Agnes","Kathy","Princess","Samantha","Vicki","Victoria","Alex","Bruce","Fred","Junior","Ralph"] @=> string names[];

	// load wav files into buffer
	SndBuf voices[11];
	for(int i; i < names.cap(); i++) {
		SndBuf v;
		0.2 => v.gain;
		me.dir() + "voices/" + names[i] + ".WAV" => v.read; // load file
		1 => v.loop; // make it loop
		0 => v.pos; 
		v @=> voices[i]; // put it into the array to control later
		v => outlet; // chuck to Chubgraph output
	}

	// --------------- END Initialization

	// play only one voice at a time
	fun void playOneAtATime(dur breakTime) {
		// set voices to initial value
		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			0 => v.gain;
			0 => v.pos; 
		}	

		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			1 => v.gain;
			breakTime => now; // wait a single voice to play
			0 => v.gain;
		}
	}

	// gradually turn each buffer up
	fun void addOneByOne(dur breakTime, int fromBeginning) {
		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			0 => v.gain;
		}	

		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			1 => v.gain;
			if (fromBeginning == 1) // when this flag is on
				0 => v.pos;			// set position to 0
			breakTime => now;
		}	
	}

	// shuffle the sequence in the array
	fun void shuffleVoices() {
		for(int i; i < names.cap(); i++) {
			Math.random2f( 0, names.cap()-1 ) => Std.ftoi => int j; // randomly chosen new index
			voices[i] @=> SndBuf from;
			voices[j] @=> SndBuf to;
			from @=> voices[j];
			to @=> voices[i];
		}
	}

	// set position of each buffer to random number
	fun void toRandomPosition() {
		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			v.samples() => int length;
			Math.random2f( 0, length ) => Std.ftoi => int randomPos; // get a random position inside the buffer
			randomPos => v.pos;
		}
	}

	// gradually change the speed
	fun void graduallyChangeSpeed(SndBuf b, float targetSpeed) {
		0.05 => float diff;
		b.rate() => float currentSpeed;
		while (Std.fabs(currentSpeed-targetSpeed) > diff) { // if the difference is bigger than diff
			// change currentSpeed toward targetSpeed by diff
			if (currentSpeed > targetSpeed) { 
				currentSpeed - diff => currentSpeed;
			} else {
				currentSpeed + diff => currentSpeed;
			}
			currentSpeed => b.rate; // set the rate
			100::ms => now; // wait and do the loop again
		}
		targetSpeed => b.rate; // finally, set it to targetSpeed when the difference is less than diff
	}

	// set rate of each buffer to random speed
	fun void setRandomSpeed(float min, float max, int gradually) {
		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			Math.random2f( min, max ) => float rate; // random speed between min and max
			if (gradually)		// when this flag is on
				spork ~ graduallyChangeSpeed(v, rate); // like updateFilter() in the example, change the value simultaneously by sporking it
			else 
				rate => v.rate; // set the rate right away
		}
	}

	fun void deactivateAllExceptOneVoice(int on, dur breakTime, int fromBeginning) {
		for(int i; i < names.cap(); i++) {
			voices[i] @=> SndBuf v;
			if (i != on) {
				0 => v.gain;
			} 
			
			breakTime => now;
		}

		// after deactivating, set pos for the remaining one if needed
		if (fromBeginning == 1) 	// when this flag is on
			0 => voices[on].pos;	// set position to 0
	}
}

// Voices v => dac;
// v.shuffleVoices();
// // v.playOneAtATime(1.5::second);
// v.toRandomPosition();
// v.addOneByOne(1::second,0);
// v.setRandomSpeed(0.5, 3, 1);
// v.setRandomSpeed(1.0, 1.0, 1);
// v.deactivateAllExceptOneVoice(3, 1::second, 1);
// 2::second => now;

