import java.lang.management {
	ManagementFactory
}


"Measures the time interval.  
   
 Usage:  
 1. Call [[start]] before each measure.  
 2. Call [[measure]] to measure time interval from the last [[start]] call.  
 
 Example:  
 
 		Clock clock = WallClock();
 		for ( item in 0 : totalRuns ) {
 			clock.start();
 			doOperation();
 			Integer interval = clock.measure( TimeUnit.seconds );
 		}
 
 Time interval is measured relative to the thread current to the caller.  
 So, if [[measure]] is called from _thread A_, then the interval is measured from the last call of [[start]]
 done on the same _thread A_.  
 "
tagged( "Options", "Clock" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared interface Clock
{
	
	"Starts time interval measure from the current time and locally for the current thread."
	shared formal void start();
	
	"Measures time interval from the last [[start]] call (in the same thread as `measure` called) and up to now.  
	 Returns time interval in the given time units [[units]]."
	shared formal Float measure( "Units the time interval is to be measured in." TimeUnit units );
	
}


"Wall clock - uses `system.nanoseconds` to measure time interval."
tagged( "Clock" )
see( `class Options`, `class CPUClock`, `class UserClock` )
since( "0.7.0" ) by( "Lis" )
shared class WallClock() satisfies Clock
{
	variable Integer startWallTime = 0;
	
	shared actual void start() {
		startWallTime = system.nanoseconds;
	}
	
	shared actual Float measure( TimeUnit units )
		=> TimeUnit.nanoseconds.factorToSeconds / units.factorToSeconds * ( system.nanoseconds - startWallTime );
	
	shared actual String string => "wall clock";
}


"Base for the CPU time interval measurements.  
 Calculates a factor to scale wall time interval corresponds to measure request.  
 The factor is moving averaged ratio of CPU time interval to wall time interval.  
 Ends of CPU time interval are measured as close as possible to ends of wall time interval.  
 
 [[readCurrentTime]] provides particular implementation of CPU or user times.
 "
since( "0.7.0" ) by( "Lis" )
shared abstract class ThreadClock() of CPUClock | UserClock satisfies Clock {
	
	variable Integer startWallTime = system.nanoseconds;
	variable Integer lastWallTime = 0;
	variable Integer lastSample = 0;
	variable Float factor = 1.0;
	
	if ( !ManagementFactory.threadMXBean.threadCpuTimeEnabled ) {
		ManagementFactory.threadMXBean.threadCpuTimeEnabled = true;
	}
	
	"Returns current time based on strategy."
	shared formal Integer readCurrentTime();
	
	shared actual void start() {
		Integer currentSample = readCurrentTime();
		Integer currentWallTime = system.nanoseconds;
		if ( lastSample > 0 && currentSample > lastSample && currentWallTime > lastWallTime ) {
			// Moving averaging factor!
			factor = 0.9 * factor + 0.1 * ( currentSample - lastSample ) / ( currentWallTime - lastWallTime );
			lastSample = currentSample;
			lastWallTime = currentWallTime;
		}
		startWallTime = system.nanoseconds;
	}
	
	shared actual Float measure( TimeUnit units )
		=> TimeUnit.nanoseconds.factorToSeconds / units.factorToSeconds * factor * ( system.nanoseconds - startWallTime );
	
}


"CPU clock uses `ThreadMXBean.currentThreadCpuTime` to measure time interval.  
 If thread CPU time is not supported measures wall time interval."
tagged( "Clock" )
see( `class Options`, `class UserClock`, `class WallClock` )
since( "0.7.0" ) by( "Lis" )
shared class CPUClock() extends ThreadClock() {
	shared actual Integer readCurrentTime() {
		value threadMXBean = ManagementFactory.threadMXBean;
		if ( threadMXBean.currentThreadCpuTimeSupported ) {
			return threadMXBean.currentThreadCpuTime;
		}
		else {
			return system.nanoseconds;
		}
	}
	shared actual String string => "CPU clock";
}


"User clock uses `ThreadMXBean.currentThreadUserTime` to measure time interval.  
 If thread CPU time is not supported measures wall time interval."
tagged( "Clock" )
see( `class Options`, `class CPUClock`, `class WallClock` )
since( "0.7.0" ) by( "Lis" )
shared class UserClock() extends ThreadClock() {
	shared actual Integer readCurrentTime() {
		value threadMXBean = ManagementFactory.threadMXBean;
		if ( threadMXBean.currentThreadCpuTimeSupported ) {
			return threadMXBean.currentThreadUserTime;
		}
		else {
			return system.nanoseconds;
		}
	}
	shared actual String string => "user clock";
}
