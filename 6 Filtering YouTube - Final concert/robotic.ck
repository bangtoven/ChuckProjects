// Jungho Bang
// 2017.12.13.
// PAT 562 Live Performance
// Main program to connect all the classes

class RoboticVoiceUI extends UIBundle {
	adc => preamp => RoboticVoice rv => dac;	
	slider.name( "Amp modulation: Robotic voice (mod frequency)" );
	slider.range( 1, 1000 );
	slider.value( 50 );

	fun void sliderChanged(float value) {
		value => rv.osc.freq;
	}
}

UIBundle bundles[2];
int count;

RoboticVoiceUI robotic @=> bundles[count++];

UIViewController vc;
for( int i; i < count; i++ ){
	vc.addBundledUI(bundles[i]);
}
vc.display();

1::hour => now;
