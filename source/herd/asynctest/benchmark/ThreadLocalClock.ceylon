import java.lang.management {
	ManagementFactory
}


"Represents clock local to thread - has to be executed from a one thread."
since( "0.7.0" ) by( "Lis" )
interface ThreadLocalClock {
	
	"Initializes the clock."
	shared formal void initialize();
	
	"Starts time interval measure from the current time."
	shared formal void start();
	
	"Measures time interval from the last [[start]] call and up to now."
	shared formal Integer measure();
}


"Wall clock uses `system.nanoseconds` to measure time interval."
since( "0.7.0" ) by( "Lis" )
class WallLocalClock() satisfies ThreadLocalClock {
	
	variable Integer startWallTime = system.nanoseconds;
	
	shared actual void start() {
		startWallTime = system.nanoseconds;
	}
	
	shared actual void initialize() {}
	
	shared actual Integer measure() => system.nanoseconds - startWallTime;
}


"Base for the CPU time interval measurements.  
 Calculates a factor to scale wall time interval corresponds to measure request.  
 The factor is moving averaged ratio of CPU time interval to wall time interval.  
 Ends of CPU time interval are measured as close as possible to ends of wall time interval.  
 
 [[readCurrentTime]] provides particular implementation of CPU or user times.
 "
since( "0.7.0" ) by( "Lis" )
abstract class ThreadClock() satisfies ThreadLocalClock {
	
	variable Integer startWallTime = system.nanoseconds;
	variable Integer lastWallTime = 0;
	variable Integer lastSample = 0;
	variable Float factor = 1.0;
	
	"Returns current time based on strategy."
	shared formal Integer readCurrentTime();

	
	shared actual void initialize() {
		value threadMXBean = ManagementFactory.threadMXBean;
		if ( !threadMXBean.threadCpuTimeEnabled ) {
			threadMXBean.threadCpuTimeEnabled = true;
		}
		lastSample = readCurrentTime();
		startWallTime = system.nanoseconds;
		lastWallTime = startWallTime;
		factor = 1.0;
	}
	
	shared actual void start() {
		Integer currentSample = readCurrentTime();
		Integer currentWallTime = system.nanoseconds;
		if ( currentSample > lastSample && currentWallTime > lastWallTime ) {
			// Moving averaging factor!
			factor = 0.9 * factor + 0.1 * ( currentSample - lastSample ) / ( currentWallTime - lastWallTime );
			lastSample = currentSample;
			lastWallTime = currentWallTime;
		}
		startWallTime = system.nanoseconds;
	}
	
	shared actual Integer measure() => ( factor * ( system.nanoseconds - startWallTime ) ).integer;
	
}


"CPU clock uses `ThreadMXBean.currentThreadCpuTime` to measure time interval."
since( "0.7.0" ) by( "Lis" )
class CPULocalClock() extends ThreadClock() {
	shared actual Integer readCurrentTime() {
		value threadMXBean = ManagementFactory.threadMXBean;
		if ( threadMXBean.currentThreadCpuTimeSupported ) {
			return threadMXBean.currentThreadCpuTime;
		}
		else {
			return system.nanoseconds;
		}
	}
}


"User clock uses `ThreadMXBean.currentThreadUserTime` to measure time interval."
since( "0.7.0" ) by( "Lis" )
class UserLocalClock() extends ThreadClock() {
	shared actual Integer readCurrentTime() {
		value threadMXBean = ManagementFactory.threadMXBean;
		if ( threadMXBean.currentThreadCpuTimeSupported ) {
			return threadMXBean.currentThreadUserTime;
		}
		else {
			return system.nanoseconds;
		}
	}
}
