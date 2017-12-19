// Jungho Bang
// 2017.10.13.
// PAT 562 Assignment #3
// filtering audio files

fun void clipSndBuf(dur myDur) {
	SndBuf buffy => LPF lpf => dac;
	"special:dope" => buffy.read;
	// "special:eee" => buffy.read;
	// "special:ahh" => buffy.read;

	4000 => lpf.freq;
	10 => lpf.Q;

	500::ms => dur T;

	<<<"\tclip start at", now/second, "seconds">>>;
	now => time myBeg;
	myBeg + myDur => time myEnd;

	spork ~ updateFilter(lpf);
	while (now < myEnd) {
		trigger(buffy, Math.random2f(.9, 1.1), 1.0);
		T => now;
	}

	<<<"\tclip end at", now/second, "seconds">>>;
}

fun void trigger(SndBuf buf, float pitch, float velocity) {
	pitch => buf.rate;
	velocity => buf.gain;
	0 => buf.pos;
}

fun void updateFilter(LPF lpf) {
	while (true) {
		400 + (Math.sin(now/second*1)+1)/2*3000 => lpf.freq;
		5::ms => now;
	}
}

dac => WvOut out => blackhole;
me.sourceDir() + "/BANG_Ex2.wav" => string _capture; 
_capture => out.wavFilename;

spork ~clipSndBuf(10::second);
10::second => now;

<<<"Program end at", now/second, "seconds">>>;

out.closeFile();
