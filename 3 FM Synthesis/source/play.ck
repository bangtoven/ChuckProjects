// Jungho Bang
// 2017.11.1.
// PAT 562 Assignment #4
// Score file to organize and control the sounds

RoboticVoice robot => dac;

ReverbPan b1pan, b2pan; // Chubgraph doesn't allow chucking for multi-channel output
dac => b1pan.output; // due to a bug in chuck, we need this way of reversed chucking to enable stereo.
dac => b2pan.output;
0.1 => b1pan.revMix; 0.1 => b2pan.revMix;

BallWithIndexFM b1 => b1pan; // we might want to change the pitch of the ball, so using indexed FM.
b1.setParameters(2.5, 6, 0.8); // set timbre of the ball. ratio=2.5, index=6. 80% elasticity
BallWithIndexFM b2 => b2pan;
b2.setParameters(0.4, 16, 0.7); // 70% elasticity. less bouncy

robot.say("here is a bouncing ball");
b1.bounce(0.5, 200);
1::second => now;

robot.say("it is dropped from 1 meter high");
spork ~ b1pan.move(-1, 1, 6::second);
b1.droppedFrom(1.0, 200); // simulate free-falling from 1.0 meter

robot.say("another ball is dropped from a bit higher location");
spork ~ b2pan.move(1, -1, 8::second);
b2.droppedFrom(1.5, 500); // drop a less elastic ball from 1.5 meter
1::second => now;

robot.say("what would happen if we drop them at the same time");
spork ~ b1pan.move(1, -1, 6::second); // they are crossing each other.
spork ~ b2pan.move(-1, 1, 8::second);
spork ~ b2.droppedFrom(1.5, 500);
b1.droppedFrom(1, 200);
1::second => now;

robot.say("how about playing some pingpong with them");
// balls bouncing to a wall with changing notes (hitting ceiling rises, floor falls). it makes streaming effect.
0.5 => b1.gain;
0.5 => b2.gain;
1  => b1pan.pan;
-1 => b2pan.pan;
for (int j; j<16; j++) {
	for (int i; i<16; i++) {
		float freq;
		if (i%2 == 0) 
			50 + i => Std.mtof => freq;
		else
			50 - i => Std.mtof => freq;

		20::ms => dur length;
		if (200-20*j > 20)
			(100-10*j)::ms => length;

		spork ~ b1.play(0.8, freq, length);
		5::ms => now;
		b2.play(0.5, freq, length-5::ms);
	}
}
1::second => now;

robot.say("before the game, let's play the anthem for our tournament");
// a theme song for our little pingpong tournament
0.5::second => now;

FMIndexSynth themeMelody => NRev themeRev => dac; // since we would want consitent timbre, using FMIndexSynth
3.5 => themeMelody.ratio;
2.0 => themeMelody.index;
themeMelody.setADSR(50::ms, 10::ms, 0.9, 100::ms);
FMIndexSynth themeCode => themeRev; // different timbre
0.75 => themeCode.ratio;
3.0 => themeCode.index;
0.4 => themeCode.gain;
themeCode.setADSR(150::ms, 50::ms, 0.8, 300::ms);
0.1 => themeRev.mix;

0.3::second => dur beat;
[12, 11, 9, 7, 5, 6, 7, 7] @=> int code[];
[[0,6], [2,2], 
[4,7], [7,1], 
[7,2], [5,1], [4,1], 
[4,2], [2,1], [0,1],
[0,2], [2,6]] @=> int melody[][]; // note and duration pair

fun void playCode() {
	48+code[0] => Std.mtof => themeCode.freq; // to prevent glide for the first note.
	for( 0=>int i; i<code.cap(); i++ ){
		themeCode.playNoteGlide(48+code[i], beat*4, 100::ms); // it takes the given time to glide.
	}
}
fun void playMelody() {
	72+melody[0][0] => Std.mtof => themeMelody.freq;
	for( 0=>int i; i<melody.cap(); i++ ){
		themeMelody.playNoteGlide(72+melody[i][0], melody[i][1]*beat, 50::ms); // get the duration from the array as well.
	}
}
spork ~ playCode();
spork ~ playMelody();
beat*36 => now;

// --- Game On

robot.say("player one");
Racket player1 => ReverbPan p1pan; // sound of racket hitting a ball. 
dac => p1pan.output;
-1 => p1pan.pan;
player1.setParameters(50, 10);
player1.introduce(0.5, 100); // it has a sound for introducing itself.
1::second => now;

robot.say("and player two");
Racket player2 => ReverbPan p2pan;
dac => p2pan.output;
1 => p2pan.pan;
player2.setParameters(0.05, 10);
player2.introduce(1.0, 10000); 
1::second => now;

robot.say("let's start the match");
spork ~ player1.introduce(0.5, 100); // greeting together
spork ~ player2.introduce(1.0, 10000);
2::second => now;

// Rally
fun void rally(BallWithIndexFM ball, ReverbPan ballPan, float freq, int startPosition, int count, float speed) {
	Swoosh swoosh; // wind sound of fast moving ball
	(startPosition==1) ? 0 : 1 => int i; // determine even/odd
	i + count => int end; // how many times
	for( i ; i<end; i++ ){
	    (i%2 == 0) ? 1 : -1 => float position; // which side

	    position*0.7 => ballPan.pan;
	    spork ~ ball.bounce(0.2, freq);
	    (0.75/speed)::second => now; // adjust the time with speed param
	    
	    if (i%2 == 0) 
	    	spork ~ player2.hit(0.08, 6000 + 2000 * Math.random2f(-1, 1), 0.2::second); // racket hitting sound
	    else 
	    	spork ~ player1.hit(0.05, 110 + 10 * Math.random2f(-1, 1), 0.2::second); // detune frequency everytime

	    position*1.0 => ballPan.pan;
	    spork ~ swoosh.wind(position, -0.8*position, 1.0, (500/speed)::ms); // wind swooshing
	    spork ~ ball.bounce(0.2, freq);
	    (1.25/speed)::second => now;
	}
}

BallWithIndexFM ball => ReverbPan ballPan;
dac => ballPan.output;
ball.setParameters(0.1, 5, 0.6);

// first point

rally(ball, ballPan, 1000,1, 6, 1); // it stopped in player 2's turn
spork ~ ballPan.move(0.5, 1, 2::second);
0.5 => ball.gain;
ball.droppedFrom(0.5, 1000); // then it falls
1.0 => ball.gain;
1::second => now;

robot.say("player 2 didn't receive the ball");
player2.falling(0.5, 8000, 2::second); // so it is sad.
1::second => now;

robot.say("player 1 gets a point");
player1.rising(0.25, 100, 2::second); // and happy
1::second => now;

// second point

robot.say("1 to 0 now, player 2 is serving");
rally(ball, ballPan, 1000, 1, 5, 1.2); // a bit faster. now player 1 lost.
spork ~ ballPan.move(-0.5, -1, 2::second);
0.5 => ball.gain;
ball.droppedFrom(0.5, 1000); 
1.0 => ball.gain;
1::second => now;

robot.say("player 2 gets a point, now it's tie");
player2.rising(0.5, 8000, 2::second); // now it's happy.
1::second => now;

robot.say("let's see whether they can play twice faster");
rally(ball, ballPan, 1000, 1, 6, 2.0); // increase the speed

robot.say("faster than that?");
rally(ball, ballPan, 1000, 1, 8, 4.0);

robot.say("they are awesome, let's throw more balls to them");

BallWithIndexFM extraBalls[5];
ReverbPan extraBallPan[5];
for(int i; i<5; i++){
	0.2 => extraBalls[i].gain;
	extraBalls[i] => extraBallPan[i];
	dac => extraBallPan[i].output;
}
extraBalls[0].setParameters(0.2, 2, 0.6);
extraBalls[1].setParameters(1.5, 2, 0.6); // Too much CPU power
extraBalls[2].setParameters(0.4, 2, 0.6);
extraBalls[3].setParameters(2.5, 2, 0.6); 
extraBalls[4].setParameters(0.8, 2, 0.6);

for(int i; i<5; i++){
	spork ~ rally(extraBalls[i], extraBallPan[i], 400+160*i, 1%2, 50, 1.5 + 0.5*i); // different timbre, freq, start location, and speed
	500::ms => now; // give little interval
}
10::second => now;

robot.say("they are perfect players, never missing");
5::second => now;

robot.say("ahhh, keep them playing, and let's leave");
fun void fadeOut(dur duration) { // fade out the dac
    for(int i; i<100; i++) {
        1 - i/100. => dac.gain;
        duration/100 => now;
    }
    0 => dac.gain;
}
spork ~ fadeOut(5::second);
5::second => now;
