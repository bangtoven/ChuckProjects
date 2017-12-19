// Jungho Bang
// 2017.12.06.
// PAT 562 Live Performance
// Groupped MAUI elements that can be inherited: LED, Button(Switch), Slider

public class UIBundle {	
	Gain preamp;
	0 => preamp.gain;

	MAUI_LED led;
	MAUI_Button button;
	MAUI_Slider slider;

	led.size( 80, led.height() );
	led.unlight();
	
	button.toggleType();
	button.size( 100, 80 );
	button.name( "Toggle" );

	slider.size( 300, slider.height() );
	
	spork ~ controlToggle();
	spork ~ controlSlider();

	fun void controlToggle() {
		while( true ){
			button => now;
			if( button.state() == 0 ){
				led.unlight();
				0 => preamp.gain;
			} else {
				led.light();
				1 => preamp.gain;
			}
		}
	}

	fun void controlSlider() {
	    while( true ) {
	        slider => now;
	        slider.value() => float value;
	        sliderChanged(value);
	    }
	}
    
    // have to be override by children
    fun void sliderChanged(float value) {}
}
