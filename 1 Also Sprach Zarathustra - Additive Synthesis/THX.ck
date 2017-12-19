// Jungho Bang
// 2017.09.26.
// PAT 562 Assignment #2
// THX tutorial

800::ms => dur initialHold;
3::second => dur sweep;
3::second => dur peakHold;
2::second => dur decay;

(sweep/samp) $ int => int sweepSteps; 
(decay/samp) $ int => int decaySteps;

30 => int nOscs;
int targetPitch[nOscs];
0 => int i;
0 => int j;

while (i < nOscs) {
	if (i%2==0) 0+(j*12) => targetPitch[i];
	else 7+(j*12) => targetPitch[i];
	if (j<8) j++;
	if (j==8) 0=>j;
	i++;
}



fun void sawVoice(float initialFreq, float targetPitch, float gain, UGen speakerNum) {
    SawOsc s => speakerNum;
	(Std.mtof(targetPitch)-initialFreq) / sweepSteps => float delta;
	gain => s.gain;
	initialFreq => s.freq;

	initialHold => now;

	now + sweep => time endOfSweep;

	0 => int j;
	while (now < endOfSweep) {
		initialFreq + (delta*j) => s.freq;
		1::samp => now;
		j++;
	}

	peakHold => now;

	now+decay => time endOfDecay;
	0 => j;

	while (now < endOfDecay) {
		gain * (decaySteps-j) / decaySteps => s.gain;
		1::samp => now;
		j++;
	}
}

2 => int nChannels;
JCRev r[nChannels];
for( int i; i < nChannels; i++ ){
	r[i] => dac.chan(i);
	0.025 => r[i].mix;
}

for (int i; i< nOscs; i++) {
    spork ~ sawVoice(Math.random2f( 200.,400.), targetPitch[i], 1.0/nOscs, r[i%2] );
}

10::second => now;
