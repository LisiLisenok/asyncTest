import java.util.concurrent {

	ScheduledThreadPoolExecutor,
	TimeUnit { milliseconds = \iMILLISECONDS }
}
import java.lang {

	Runnable
}


"Performs scheduling using thread pool."
by( "Lis" )
shared class Scheduler (
	"The number of threads to keep in the pool, even if they are idle."
	Integer corePoolSize
) {
	
	"Scheduler to run timers."
	ScheduledThreadPoolExecutor executor = ScheduledThreadPoolExecutor( corePoolSize );
	
	
	"Represent a timer running on `ScheduledThreadPoolExecutor`."
	class Timer (
		Iterator<Integer> delays,
		void onFire(),
		void onComplete(),
		void onError( Throwable err )
	)
			satisfies Runnable
	{
		
		"Shifts to the next fire time."
		shared void next() {
			if ( is Integer delay = delays.next() ) {
				if ( delay > 0 ) {
					try {
						executor.schedule( this, delay, milliseconds );
					}
					catch ( Throwable err ) {
						onError( err );
					}
				}
				else {
					onError( NonpositiveDelayException( delay ) );
				}
			}
			else {
				onComplete();
			}
		}
		
		shared actual void run() {
			onFire();
			next();
		}
	}
	
	
	"Schedules timer.  
	 [[delays]] iterator provides delays in milliseconds to next fire time.  
	 When timer fires [[onFire]] is called and [[delays]] is shifted to next value, so variable delay can be specified.  
	 When [[delays]] is exhausted [[onComplete]] is called.  "
	shared void schedule (
		"Delays iterator, in milliseconds."
		Iterator<Integer> delays,
		"Timer fire callback."
		void onFire(),
		"Timer completed callback"
		void onComplete(),
		"Callback to notify some error is occured"
		void onError( Throwable err )
	) {
		value timer = Timer( delays, onFire, onComplete, onError );
		timer.next();
	}
	
	
	"Stops all timers"
	shared void stopAll() {
		try {
			executor.shutdownNow();
			executor.shutdown();
		}
		catch ( Throwable err ) {}
	}
	
}
