// Jungho Bang
// 2017.10.13.
// PAT 562 Assignment #3
// chip tunes

fun void clipSqr(dur myDur) {
	SqrOsc sqr => LPF lpf => ADSR env => dac;
	4000 => lpf.freq;
	env.set(10::ms, 5::ms, .5, 10::ms);
	120::ms => dur T;

	spork ~ updateFilter(lpf);

	<<<"\tclip start at", now/second, "seconds">>>;
	now => time myBeg;
	myBeg + myDur => time myEnd;

	while (now < myEnd) {
		play (sqr, env, 60, 1., T);
		play (sqr, env, 67, .5, T);
		play (sqr, env, 70, .6, T);
		play (sqr, env, 72, .8, T);
		play (sqr, env, 76, .3, T);
		play (sqr, env, 82, .5, T);
		play (sqr, env, 84, .7, T);
		play (sqr, env, 91, .9, T);
	}
	<<<"\tclip end at", now/second, "seconds">>>;
}

fun void updateFilter(LPF lpf) {
	while (true) {
		400 + (Math.sin(now/second*1)+1)/2*3000 => lpf.freq;
		5 => lpf.Q;
		5::ms => now;
	}
}

fun void play(SqrOsc sqr, ADSR env, float pitch, float velocity, dur T  ) {
	pitch => Std.mtof => sqr.freq;
	velocity => sqr.gain;
	env.keyOn();
	T-env.releaseTime() => now;
	env.keyOff();
	env.releaseTime() => now;
}

dac => WvOut out => blackhole;
me.sourceDir() + "/BANG_Ex3.wav" => string _capture; 
_capture => out.wavFilename;

spork ~clipSqr(10::second);
10::second => now;

<<<"Program end at", now/second, "seconds">>>;

out.closeFile();
