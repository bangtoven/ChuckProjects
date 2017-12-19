// Jungho Bang
// 2017.10.17.
// PAT 562 Assignment #3
// Main code to connect all the files for this assignment

Machine.add(me.dir() + "Voices.ck"); // To generate white-noise-like sound

Machine.add(me.dir() + "WhistleFilter.ck");
Machine.add(me.dir() + "AverageFilter.ck");
Machine.add(me.dir() + "FeedforwardCombFilter.ck");
Machine.add(me.dir() + "FeedbackCombFilter.ck");
Machine.add(me.dir() + "FormantFilter.ck");

Machine.add(me.dir() + "score.ck");
