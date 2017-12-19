// Jungho Bang
// 2017.11.09.
// PAT 562 Assignment #5
// Parser for Apple Health data
// Credit: Chris Chafe (Borrowed some code from DataReader class for FildIO)

public class HealthData {
	int startDate;	// represent time point of the action. e.g. 17:21:33
	int endDate;	// in this model, it is converted to seconds.
	float value;	// this can be heartrate, energy, or steps.

	int duration;	// endDate - startDate
	float rate;		// for some data, we want rate as well.

	string startStr;// raw values
	string endStr;
	string type;
	string unit;

	fun static HealthData[] parseDataFromFile(string path) {
		FileIO in; // file pointer
		5 => int columns;

		in.open( me.dir() + path, FileIO.READ );
		if( !in.good() ) {
	    	<<< "can't open file: ", path, " for reading">>>;
	    	return null;
		}

		string rawString;
		while (!in.eof()) {
	    	in.readLine()+"\n" +=> rawString;
	    }
	    
		StringTokenizer tok; // make tokenizer
		tok.set( rawString ); // set the string to parse

		tok.size() => int numTokens;
		numTokens / columns => int size; // get number of entries
		string parsed[size][columns];

		0 => int row;
		while( tok.more() ) {
			for(0 => int i; i < columns; i++) { // iterated on column
				tok.next() @=> parsed[row][i];
			}
			row++; // for each row
		}

		HealthData data[parsed.cap()];
		for( int i; i<parsed.cap(); i++ ){
			HealthData d @=> data[i];
			d.init(parsed[i]); // call member method 'init'
		}
		return data;
	}

	fun void init(string data[]) { // initialize with the raw string array 
		data[0] => startStr;
		data[1] => endStr;
		data[2] => type; 
		data[3] => Std.atof => value;
		data[4] => unit;

		startStr => convertTime => startDate; // convert date string to seconds
		endStr => convertTime => endDate;
		
		endDate - startDate => duration;

		if (duration != 0) {
			value / duration => rate; // for some data, we want rate as well.
		} else {
			-1 => rate;
		}
	}

	fun static int convertTime(string timeStr) {
		timeStr.substring(0, 2) => Std.atoi => int hh; // split string
		timeStr.substring(3, 2) => Std.atoi => int mm;
		timeStr.substring(6, 2) => Std.atoi => int ss;

		hh*3600 + mm*60 + ss => int seconds; // convert to seconds
		return seconds; // becomes integer
	}

	fun void print() {
		<<<type, startDate, endDate, duration, value, unit, rate>>>;
	}

	fun static void printArray(HealthData data[]) {
		for( int i; i<data.cap(); i++ ){
			data[i].print();
		}
	}

	// check whether startDate increases
	fun static void timeCheckStart(HealthData data[]) {
		for( 1 => int i; i<data.cap(); i++ ){
			if (data[i].startDate <= data[i-1].startDate) {
				<<<"inconsistency found!">>>;
				data[i-1].print();
				data[i].print();
				<<<"---------">>>;
			}
		}	
	}

	// check whether next start is after previous end.
	// it seems like apple health's timing overlap.
	fun static void timeCheckEndStart(HealthData data[]) {
		for( 1 => int i; i<data.cap(); i++ ){
			if (data[i].startDate < data[i-1].endDate) {
				<<<"inconsistency found!">>>;
				data[i-1].print();
				data[i].print();
				<<<"---------">>>;
			}
		}	
	}
}

// HealthData.parseDataFromFile( me.dir() + "ActiveEnergy.txt" ) @=> HealthData ActiveEnergy[];
// HealthData.parseDataFromFile( me.dir() + "BasalEnergy.txt" ) @=> HealthData BasalEnergy[];
// HealthData.parseDataFromFile( me.dir() + "DistanceSwimming.txt" ) @=> HealthData DistanceSwimming[];
// HealthData.parseDataFromFile( me.dir() + "HeartRate.txt" ) @=> HealthData HeartRate[];
// HealthData.parseDataFromFile( me.dir() + "StrokeCount.txt" ) @=> HealthData StrokeCount[];

// HealthData.printArray(ActiveEnergy);
// HealthData.printArray(BasalEnergy);
// HealthData.printArray(DistanceSwimming);
// HealthData.printArray(HeartRate);
// HealthData.printArray(StrokeCount);

// HealthData.timeCheckStart(ActiveEnergy);
// HealthData.timeCheckStart(BasalEnergy);
// HealthData.timeCheckStart(DistanceSwimming);
// HealthData.timeCheckStart(HeartRate);
// HealthData.timeCheckStart(StrokeCount);

// HealthData.timeCheckEndStart(ActiveEnergy);
// HealthData.timeCheckEndStart(BasalEnergy);
// HealthData.timeCheckEndStart(DistanceSwimming);
// HealthData.timeCheckEndStart(HeartRate);
// HealthData.timeCheckEndStart(StrokeCount);

