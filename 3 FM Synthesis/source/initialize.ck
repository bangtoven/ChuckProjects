// Jungho Bang
// 2017.11.1.
// PAT 562 Assignment #4
// Main code to connect all the files for this assignment

Machine.add(me.dir() + "JHReverbPan.ck"); // To enable reverb + panning

Machine.add(me.dir() + "FMSynth_Lab.ck"); // My implementation of the lab assignment
Machine.add(me.dir() + "FMIndexSynth.ck"); // FMSynth using index and C-M ratio

Machine.add(me.dir() + "RoboticVoice.ck"); // Filter to make robotic narration using AM synth
Machine.add(me.dir() + "Swoosh.ck"); // Wind sound of fast moving ball
Machine.add(me.dir() + "Ball.ck"); // Simulating a free-falling bouncing ball
Machine.add(me.dir() + "BallWithIndexFM.ck"); // Modelling a ball using FMIndexSynth
Machine.add(me.dir() + "Racket.ck"); // Sound for a racket/player

Machine.add(me.dir() + "play.ck"); // score (or play script) file
