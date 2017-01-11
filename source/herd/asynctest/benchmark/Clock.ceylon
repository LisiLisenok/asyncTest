import java.lang.management {
	ManagementFactory
}
import java.lang {
	ThreadLocal
}
import java.util.\ifunction {
	Supplier
}


"Measures the time interval with one of the three strategies:  
 
 1. [[wall]] time, i.e. the time provided by system wall clocks.  
 2. [[cpu]] thread time which is time the thread occupies a CPU.  
 3. Thread [[user]] time which is time the thread occupies a CPU in user mode, rather than in system mode.  
 
 > Note: `cpu` and `user` times are evaluated approximately.  
 
 
 Usage:  
 1. Call [[initialize]] before measure cycle.    
 2. Call [[start]] before each measure.  
 3. Call [[measure]] to measure time interval from the last [[start]] call.  
 
 Example:  
 
 		Clock clock = Clock.wall;
 		clock.initialize();
 		for ( item in 0 : totalRuns ) {
 			clock.start();
 			doOperation();
 			Integer interval = clock.measure();
 		}
 
 Time interval is measured relative to the thread current to the caller.  
 So, if [[measure]] is called from _thread A_, then the interval is measured from the last call of [[start]]
 done on the same _thread A_.  
 "
tagged( "Options" )
see( `class Options` )
since( "0.7.0" ) by( "Lis" )
shared class Clock
		of cpu | user | wall
{
	
	"Instantiates new local to the thread clock."
	ThreadLocalClock() instantiate;
	
	shared actual String string;
		
	
	"Indicates that `ThreadMXBean.currentThreadCpuTime` has to be used for time measurement.  
	 If CPU time is not supported uses `system.nanoseconds`."
	shared new cpu {
		// TODO: log clock selection?
		if ( ManagementFactory.threadMXBean.threadCpuTimeSupported ) {
			string = "CPU clock";
			instantiate = CPULocalClock;
		}
		else {
			string = "wall clock";
			instantiate = WallLocalClock;
		}
	}
	
	"Indicates that `ThreadMXBean.currentThreadUserTime` has to be used for time measurement.  
	 If CPU time is not supported uses `system.nanoseconds`."
	shared new user {
		// TODO: log clock selection?
		if ( ManagementFactory.threadMXBean.threadCpuTimeSupported ) {
			string = "CPU user clock";
			instantiate = UserLocalClock;
		}
		else {
			string = "wall clock";
			instantiate = WallLocalClock;
		}
	}
	
	"Indicates that `system.nanoseconds` has to be used for time measurement."
	shared new wall {
		string = "wall clock";
		instantiate = WallLocalClock;
	}
	
	
	ThreadLocal<ThreadLocalClock> localClock = ThreadLocal.withInitial (
		object satisfies Supplier<ThreadLocalClock> {
			get() => instantiate();
		}
	);

	
	"Initializes the clock locally for the current thread.  
	 Has to be called before any measurements."
	shared void initialize() => localClock.get().initialize();
	
	"Starts time interval measure from the current time and locally for the current thread."
	shared void start() => localClock.get().start();
	
	"Measures time interval from the last [[start]] call (in the same thread as `measure` called) and up to now."
	shared Integer measure() => localClock.get().measure();
	
}
