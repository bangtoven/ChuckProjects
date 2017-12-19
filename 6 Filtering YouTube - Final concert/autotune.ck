// Jungho Bang
// 2017.12.13.
// PAT 562 Live Performance
// Main program to connect all the classes

class ByPassUI extends UIBundle {
    adc => preamp => dac;
    
    slider.name( "Input sound without filter. (Gain)" );
    slider.range( 0, 1 );
    slider.value( 1 );
    
    fun void sliderChanged(float value) {
        value => preamp.gain;
    }
}

class AutoTuneUI extends UIBundle {
	adc => preamp => JHAutoTune autotune => dac;	
	slider.name( "Auto-tune fixed (no slider control)" );
	slider.range( 0, 1 );
	slider.value( 0 );
	[0, 3, 7, 10] @=> autotune.keys;
	1 => autotune.mode; // find closest among given list of pitches
    1 => autotune.active;

	fun void sliderChanged(float value) {
		
	}
}

class AutoTuneShiftUI extends UIBundle {
    adc => preamp => JHAutoTune autotune => dac;	
    slider.name( "Pitch shift" );
    slider.range( 0.1, 4.0 );
    Math.random2f( 0.1, 4.0 ) => float value;
    slider.value( value );
    3 => autotune.mode; // find closest among given list of pitches
    1 => autotune.active;
    value => autotune.shift;
    
    fun void sliderChanged(float value) {
        value => autotune.shift;
    }
}

UIBundle bundles[6];
int count;

ByPassUI bp @=> bundles[count++];
AutoTuneUI at @=> bundles[count++];
at.slider.name( "Auto-tune Cm7 (no slider control)" );
AutoTuneUI at2 @=> bundles[count++];
[0, 5] @=> at2.autotune.keys;
at2.slider.name( "Auto-tune F (no slider control)" );
AutoTuneShiftUI ats0 @=> bundles[count++]; 
AutoTuneShiftUI ats1 @=> bundles[count++];
AutoTuneShiftUI ats2 @=> bundles[count++];


UIViewController vc;
for( int i; i < count; i++ ){
	vc.addBundledUI(bundles[i]);
}
vc.display();

1::hour => now;
