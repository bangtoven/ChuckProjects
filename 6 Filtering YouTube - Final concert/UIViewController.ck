// Jungho Bang
// 2017.12.06.
// PAT 562 Live Performance
// Class for managing UIBundle instances

public class UIViewController {
	MAUI_View view;
	int count;

	fun void addBundledUI(UIBundle bundle){
		count*100 => int y; 

	    bundle.led.position(10, y+10);
	    bundle.button.position(bundle.led.x() + bundle.led.width(), y);
	    bundle.slider.position(bundle.button.x() + bundle.button.width(), y);

        view.addElement(bundle.led);
        view.addElement(bundle.button);
        view.addElement(bundle.slider);
	    
	    count++;
	}

	fun void display() {
		view.size(500, count*100); // determines the height with the number of elements
		view.display();
	}
}
