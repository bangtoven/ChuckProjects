// Jungho Bang
// 2017.10.27.
// PAT 562 Assignment #4
// Enable Panning with Reverb

public class ReverbPan extends Chubgraph {	
    inlet => Pan2 p;
    NRev lRev;// => outlet.chan(0); // this code doesn't work. 
    NRev rRev;// => outlet.chan(1); // outlet.chan(1) gives nullptr exeption. seems Chuck's bug

    fun void output(UGen o) {
        lRev => o.chan(0);
        rRev => o.chan(1);
    }
    
    // share input with other side
    // e.g. left-out has some reverb of right-in
    p.left => Gain ll => lRev;
    p.left => Gain lr => rRev;
    p.right => Gain rr => rRev;
    p.right => Gain rl => lRev;
    weight(0.99);
    revMix(0.1);

    fun void pan(float newP) {
        newP => p.pan;
    }
    
    fun void revMix(float newM) {
        newM => lRev.mix => rRev.mix;
    }
    
    fun void weight(float newWeight) {
        newWeight => ll.gain => lr.gain;
        1-newWeight => lr.gain => rl.gain;
    }

    // update panning gradually
    fun void move(float from, float to, dur duration) {
        if (duration == 0::samp) {
            to => p.pan;
        } else {
            from => p.pan;
            for(int i; i<100; i++) {
                from + (to-from)*i/100.0 => p.pan;
                duration/100 => now;
            }
            to => p.pan;
        }
    }
}
