

"Specifies time unit."
tagged( "Options" )
see( `class Options`, `class Result` )
since( "0.7.0" ) by( "Lis" )
shared class TimeUnit
	of seconds | milliseconds | microseconds | nanoseconds | minutes | hours
{
	
	"Factor to seconds."
	shared Float factorToSeconds;
	
	"Short designation."
	shared String shortString;
	
	shared actual String string;
	
	"Seconds."
	shared new seconds {
		factorToSeconds = 1.0;
		shortString = "s";
		string = "seconds";
	}
	
	"Milliseconds."
	shared new milliseconds {
		factorToSeconds = 1.0e-3;
		shortString = "ms";
		string = "milliseconds";
	}
	
	"Microseconds."
	shared new microseconds {
		factorToSeconds = 1.0e-6;
		shortString = "micros";
		string = "microseconds";
	}
	
	"Nanoseconds."
	shared new nanoseconds {
		factorToSeconds = 1.0e-9;
		shortString = "ns";
		string = "nanoseconds";
	}
	
	"Minutes."
	shared new minutes {
		factorToSeconds = 60.0;
		shortString = "m";
		string = "minutes";
	}
	
	"Hours."
	shared new hours {
		factorToSeconds = 3600.0;
		shortString = "h";
		string = "hours";
	}
	
}
