// Jungho Bang
// 2017.12.06.
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

class WhistleFilterUI extends UIBundle {
	adc => preamp => WhistleFilter filter => dac;

	slider.name( "Whistle filter (frequency)" );
	slider.range( 100, 10000 );
	slider.value( 500 );
	filter.setFrequency(500, 0);

	fun void sliderChanged(float value) {
		filter.setFrequency(value, 1);
	}
}

class FeedforwardCombUI extends UIBundle {
	adc => preamp => FeedforwardCombFilter filter => dac;

	slider.name( "Feed forward comb filter (frequency)" );
	slider.range( 100, 10000 );
	slider.value( 500 );
	filter.setFrequency(500);

	fun void sliderChanged(float value) {
		filter.setFrequency(value);
	}
}

class FeedbackCombUI extends UIBundle {
	adc => preamp => FeedbackCombFilter filter => dac;

	slider.name( "Feed back comb filter (frequency)" );
	slider.range( 100, 10000 );
	slider.value( 500 );
	filter.setFrequency(500);

	fun void sliderChanged(float value) {
		filter.setFrequency(value);
	}
}

class AverageFilterUI extends UIBundle {
	adc => preamp => AverageFilter filter => dac;

	slider.name( "Average filter (frequency)" );
	slider.range( 100, 10000 );
	slider.value( 500 );
	filter.setFrequency(500);

	fun void sliderChanged(float value) {
		filter.setFrequency(value);
	}
}

class FormantFilterUI extends UIBundle {
	adc => preamp => FormantFilter filter => dac;

	slider.name( "Vowel (select: i:, i, 3:, e, ae, ^, a:, a, o , u, u:)" );
	slider.range( 0, 10 );
	slider.value( 0 );
	slider.precision( 1 );
	
	fun void sliderChanged(float value) {
		value => Math.round => Std.ftoi => int i;
		filter.sayFormant(i);
	}
}

UIBundle bundles[6];
int count;

ByPassUI bp @=> bundles[count++];
WhistleFilterUI wf @=> bundles[count++];
FeedforwardCombUI ffc @=> bundles[count++];
FeedbackCombUI fbc @=> bundles[count++];
AverageFilterUI avg @=> bundles[count++];
FormantFilterUI ff @=> bundles[count++];

UIViewController vc;
for( int i; i < count; i++ ){
	vc.addBundledUI(bundles[i]);
}
vc.display();

1::hour => now;
