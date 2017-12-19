// Jungho Bang
// 2017.10.10.
// PAT 562 Assignment #5
// Water splash sound effect based on the HW3 ocean wave lab

public class WaterSplash extends Chubgraph{
    Noise n;
    0.5 => n.gain;
        
    fun void updateFreq(ResonZ f, float from, float to, dur duration) { // gradually change the freq of BPF
        from => f.freq;
        for(int i; i<100; i++) {
            from + (to-from)*i/100.0 => f.freq;
            duration/100 => now;
        }
        to => f.freq;
    }

    fun void splash() {
        n => ResonZ bpf => ADSR adsr => outlet; // make new BPF
        1 => bpf.Q; // as we did on ocean wave lab
        adsr.set( 100::ms, 100::ms, 0.8, 1000::ms );  
    
        adsr.keyOn(); // play

        500 + Math.random2( -200, 200 ) => float freqFrom; // randomly decide freq range
        200 + Math.random2( -100, 100 ) => float freqTo;
        spork ~ updateFreq(bpf, freqFrom, freqTo, 1.5::second); // spork freq updating

        (0.5+Math.random2f( 0, 0.3 ))::second => now; // randomly decide duration 
        adsr.keyOff();

        1::second => now; // wait for release
    }
}


// for(int i; i<10; i++) {
//     WaterSplash water => dac;
//     water.splash();
//     0.1::second => now;
// }
