adc => LPF boost => ADSR env => Dyno comp => Gain mix => dac;
MAUI_Slider slider;
slider.name("BOOST");
slider.range(0.1,1.);
slider.display();

200::ms => dur length;
env.set(1::ms, length, .5, 5::ms);

Hid hi;
HidMsg msg;
//CHANGE NUMBER IF YOUR KEYBOARD DOESN'T WORK
0 => int device;
if( me.args() ) me.arg(0) => Std.atoi => device;
if( !hi.openKeyboard( device ) ) me.exit();

while (true) {
slider.value() => float i;

comp.releaseTime(200::ms);
scaleThreshold(i);
scaleRatio(i);
scaleAttackTime(i);
scaleGain(i);
scaleBoost(i);

if (hi.recv(msg)) {
    if (msg.isButtonDown()) {
        env.keyOn();
    }
    else {
        env.keyOff();
    }
}

1::ms => now;
}

fun void scaleThreshold(float f) {
    .7 => float min;
    .1 => float max;
    comp.thresh(min+(f*(max-min)));
}

fun void scaleRatio(float f) {
    4.0 => float min;
    20.0 => float max;
    comp.ratio(min+(f*(max-min)));
}

fun void scaleAttackTime(float f) {
    48::ms => dur min;
    150::ms => dur max;
    comp.attackTime(min+(f*(max-min)));
}

fun void scaleGain(float f) {
    5.0 => float min;
    60.0 => float max;
    min+(f*(max-min)) => float g;
    mix.gain(g);
}

fun void scaleBoost(float f) {
    500.0 => float min;
    60.0 => float max;
    boost.set(min+(f*(max-min)), 2.);
}
