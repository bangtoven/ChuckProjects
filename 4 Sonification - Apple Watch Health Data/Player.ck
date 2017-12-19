// Jungho Bang
// 2017.11.09.
// PAT 562 Assignment #5
// Sound player for AppleHealthData class

// ------ Load and Parse Data
HealthData.parseDataFromFile("DistanceSwimming.txt")@=> HealthData distanceSwimming[]; // Panning
HealthData.parseDataFromFile("HeartRate.txt") 		@=> HealthData heartRate[]; // Beeping using heartBPM
HealthData.parseDataFromFile("StrokeCount.txt") 	@=> HealthData strokeCount[]; // Trigger water splash effect
HealthData.parseDataFromFile("ActiveEnergy.txt") 	@=> HealthData activeEnergy[]; // Carrier Frequency


// ------ Timing for the piece
HealthData.convertTime("17:34:00") => int timeZero; // integer representation of 5:34:00 PM

10.0 => float RATE; // 10 times faster speed than the timing of original data
fun dur convertDuration(int next, int current) {
	return ((next-current)/RATE)::second; // convert duration with RATE value.
}


// ------ Signal Flow
Gain mix => ReverbPan revPan; // Change panning for each lap.
0.05 => revPan.revMix;
dac => revPan.output; // due to a bug in chuck, we need this way of reversed chucking to enable stereo.

WaterSplash water => mix; // Play sound for each stroke.

FMIndexSynth heart => mix; // HeartRate determines rhythm.
heart.setADSR(50::ms, 10::ms, 0.8, 100::ms);
heart.setParameters(1.5, 4); // Energy burning determines carrier frequency.


// ------ Heart Rate => BPM of Beeping
1 => int keepBeating;
70 => float heartBPM;
100 => float heartFreq;
fun void heartBeat() {
	while (keepBeating) { // Obviously, heart beat should never stop...
		heartFreq => heart.freq; // update heart beat freq;

		(1.0/heartBPM)::minute => dur mpb; // inverse of heartBPM is minute/beat
		
		50::ms => dur beat;
		heart.keyOn();
		beat => now;
		heart.keyOff();
		mpb - beat => now; // total duration == mpb
	}
}

fun void playHeartRate() {
	convertDuration(heartRate[0].startDate, timeZero) => now; // wait until the first event

	for(0 => int i; i<heartRate.cap()-1; i++) {
		heartRate[i] @=> HealthData current;
		current.value => heartBPM; // update BPM
		<<<"Heart Rate Updated: ", heartBPM>>>;

		heartRate[i+1] @=> HealthData next;
		convertDuration(next.startDate, current.startDate) => dur interval;
		interval => now; // wait until next event
	}
}


// ------ Distance Swimming => Speed of Pan Update
fun void updatePanning(HealthData data, int direction, dur interval) {
	direction==0 ? -1 : 1 => int from;
	direction==0 ? 1 : -1 => int to;

	convertDuration(data.endDate, data.startDate) => dur duration; // duration of this event
	if (interval < duration) // interval: duration between this and next event
		interval => duration; // in some cases, apple health starts new event before the previous one finishes.

	if (duration == 0::samp) {
        to => revPan.pan;
    } else {
        from => revPan.pan;
        for(int i; i<100; i++) {
            from + (to-from)*i/100.0 => revPan.pan; // gradually change
            duration/100 => now;
        }
        to => revPan.pan;
    }
}

fun void playDistanceSwimming() {
	convertDuration(distanceSwimming[0].startDate, timeZero) => now; // wait until the first event

	for(0 => int i; i<distanceSwimming.cap()-1; i++) {
		<<<"Lap", i+1>>>;
		
		distanceSwimming[i] @=> HealthData current;
		distanceSwimming[i+1] @=> HealthData next;
		convertDuration(next.startDate, current.startDate) => dur interval;
		
		i%2 => int direction; // change direction everytime
		spork ~ updatePanning(current, direction, interval);
		
		interval => now;
	}
}


// ------ Stroke Count => Trigger Water Splash 
fun void waterSplash(HealthData data) {
	data.value => Std.ftoi => int strokes;
	convertDuration(data.endDate, data.startDate) => dur duration;
	duration/strokes => dur interval;

	for(int i; i<strokes; i++) { // for each stroke
		spork ~ water.splash(); // trigger splash sound
		interval => now;
	}
	2::second => now; // for enough reverb
}

fun void playStrokeCount() {
	convertDuration(strokeCount[0].startDate, timeZero) => now; // wait until the first event

	for(0 => int i; i<strokeCount.cap()-1; i++) {
		strokeCount[i] @=> HealthData current;
		strokeCount[i+1] @=> HealthData next;
		convertDuration(next.startDate, current.startDate) => dur interval;
		spork ~ waterSplash(current); // play splash stroke-count times
		
		interval => now;
	}
}


// ------ Active Energy => Carrier Frequency
fun float interpolateInRange(float outMin, float outMax, float inMin, float inMax, float value) {
	outMax - outMin => float outRange;
	inMax - inMin => float inRange;
	value - inMin => float relative;
	
	relative / inRange * outRange + outMin => float interpolated; // interpolation
	return interpolated;
}

fun void playActiveEnergy() {
	float minVal, maxVal;
	99999 => minVal; // big number
	-1 => maxVal; 
	for(0 => int i; i<activeEnergy.cap()-1; i++) {
		activeEnergy[i] @=> HealthData current;
		Math.min( minVal, current.rate ) => minVal;
		Math.max( maxVal, current.rate ) => maxVal;
	}
	<<<"ActiveEnergy", minVal, maxVal>>>; // get range to scale the value

	convertDuration(activeEnergy[0].startDate, timeZero) => now; // wait until the first event

	for(0 => int i; i<activeEnergy.cap()-1; i++) {
		activeEnergy[i] @=> HealthData current;
		current.rate => float energy; 
		interpolateInRange(50, 2000, minVal, maxVal, energy) => heartFreq; // interpolated value in 50~10000 range
		
		activeEnergy[i+1] @=> HealthData next;
		convertDuration(next.startDate, current.startDate) => dur interval;
		interval => now;
	}
}


// ------ Playing
spork ~ heartBeat(); // heart beat should never stop
spork ~ playActiveEnergy(); // energy burning rate will decide note frequency

// I started Swimming from 5:36 PM
spork ~ playDistanceSwimming();
spork ~ playStrokeCount();

playHeartRate(); // finish the piece when there's no heart rate data.
0 => keepBeating;
5::second => now;
