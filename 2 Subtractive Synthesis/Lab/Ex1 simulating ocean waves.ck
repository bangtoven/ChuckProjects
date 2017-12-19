// Jungho Bang
// 2017.10.10.
// PAT 562 Assignment #3
// simulating ocean waves

fun void clip(dur myDur) {
    Noise n => ResonZ f => dac;
    1 => f.Q;
    .25 => f.gain;
    0.0 => float t;

    now => time myBeg;
    myBeg + myDur => time myEnd;

    while (now < myEnd) {
    	//100. + (1+Math.sin(t))/2 * 3000. => f.freq;
    	24 + (1+Math.sin(t))/2 * 48 => Std.mtof => f.freq;
    	t+.005 => t;
    	5::ms => now;
    }
    <<<"\tclip end at", now/second, "seconds">>>;
}

dac => WvOut out => blackhole;
me.sourceDir() + "/BANG_Ex1.wav" => string _capture; 
_capture => out.wavFilename;

 spork ~clip(10::second);
10::second => now;

<<<"Program end at", now/second, "seconds">>>;

out.closeFile();
