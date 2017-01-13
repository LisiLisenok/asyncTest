import java.lang {
	ThreadLocal
}
import java.util.\ifunction {
	Supplier
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
 			Integer interval = clock.measure();
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
	
	"Units the clock measures time interval in."
	shared formal TimeUnit units;
	
	"Starts time interval measure from the current time and locally for the current thread."
	shared formal void start();
	
	"Measures time interval from the last [[start]] call (in the same thread as `measure` called) and up to now."
	shared formal Integer measure();
	
}


"Wall clock - uses `system.nanoseconds` to measure time interval."
tagged( "Clock" )
see( `class Options`, `class CPUClock`, `class UserClock` )
since( "0.7.0" ) by( "Lis" )
shared class WallClock() satisfies Clock
{
	ThreadLocal<Integer> startWallTime = ThreadLocal<Integer>();
	
	shared actual TimeUnit units => TimeUnit.nanoseconds;
	
	shared actual void start() {
		startWallTime.set( system.nanoseconds );
	}
	
	shared actual Integer measure() => system.nanoseconds - startWallTime.get();
	
	shared actual String string => "wall clock";	
}


"CPU clock uses `ThreadMXBean.currentThreadCpuTime` to measure time interval."
tagged( "Clock" )
see( `class Options`, `class UserClock`, `class WallClock` )
since( "0.7.0" ) by( "Lis" )
shared class CPUClock() satisfies Clock
{

	ThreadLocal<ThreadLocalClock> localClock = ThreadLocal.withInitial (
		object satisfies Supplier<ThreadLocalClock> {
			get() => CPULocalClock();
		}
	);

	shared actual TimeUnit units => TimeUnit.nanoseconds;
		
	shared actual void start() => localClock.get().start();
	
	shared actual Integer measure() => localClock.get().measure();

	shared actual String string => "CPU clock";
}


"User clock uses `ThreadMXBean.currentThreadUserTime` to measure time interval."
tagged( "Clock" )
see( `class Options`, `class CPUClock`, `class WallClock` )
since( "0.7.0" ) by( "Lis" )
shared class UserClock() satisfies Clock
{
	
	ThreadLocal<ThreadLocalClock> localClock = ThreadLocal.withInitial (
		object satisfies Supplier<ThreadLocalClock> {
			get() => UserLocalClock();
		}
	);
	
	shared actual TimeUnit units => TimeUnit.nanoseconds;
	
	shared actual void start() => localClock.get().start();
	
	shared actual Integer measure() => localClock.get().measure();
	
	shared actual String string => "User clock";
}
