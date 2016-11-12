import java.lang {
	Thread,
	ThreadDeath,
	ThreadGroup,
	SecurityException
}


"Represents group of the context - run main function, listens uncaught exceptions and interrupt all threads."
since( "0.6.0" ) by( "Lis" )
shared class ContextThreadGroup( String title )
{
	
	"Thread group."
	class InternalThreadGroup() extends ThreadGroup( title ) {
		
		variable Anything( Thread, Throwable )? uncaughtExceptionListener = null;
	
		"Reused thread or null if has to be initialized."
		variable ReusableThread? reusedThread = null;
	
		variable Boolean hasBeenInterrupted = false;
		"The group has been interrupted."
		shared Boolean groupInterrupted => hasBeenInterrupted;
		
	
		"Creates new thread or returns reused one."
		ReusableThread getThread() {
			if ( exists ret = reusedThread ) {
				return ret;
			}
			else {
				ReusableThread ret = ReusableThread( this, "failOnTimeout" );
				reusedThread = ret;
				ret.start();
				return ret;
			}
		}
	
		shared actual void uncaughtException( Thread t, Throwable e ) {
			if ( is ThreadDeath e ) {
				super.uncaughtException( t, e );
			}
			else {
				if ( exists listener = uncaughtExceptionListener ) {
					listener( t, e );
					interruptAllThreads();
				}
				else {
					// TODO: log - ?
					//super.uncaughtException( t, e );
				}
			}
		}

		"Interrupts all threads belong to the group like `ThreadGroup.interrupt` but doesn't throw."
		void interruptAllThreads() {
			hasBeenInterrupted = true;
			uncaughtExceptionListener = null;
			completeCurrent();
			// interrupt may cause security exception - we may do nothing with
			try { interrupt(); }
			catch ( SecurityException err ) {
				// TODO: log - ?
			}
		}

	
		"Stops the current thread."
		shared void completeCurrent() {
			if ( exists r = reusedThread ) {
				r.complete();
				reusedThread = null;
			}
		}
	
		"Executes `run` on separated thread belongs to this group.
		 Awaits completion no more then `timeoutMilliseconds` or unlimited if it is <= 0."
		shared Boolean execute (
			"Listener on uncaught exceptions." Anything( Thread, Throwable ) uncaughtExceptionListener,
			"Timeout in millieconds, <= 0 if unlimited." Integer timeoutMilliseconds,
			"Function to be executed on separated thread." Anything() run
		) {
			this.uncaughtExceptionListener = uncaughtExceptionListener;
			// create new thread or reuse current one
			ReusableThread thr = getThread();
			// execute the function and take latcher to await completion
			LatchWaiter latch = thr.execute( run );
			// await until timeout or completion if timeout <= 0 await completion or unlimited time
			if ( !latch.awaitUntil( timeoutMilliseconds ) ) {
				interruptAllThreads();
				return false;
			}
			else {
				return true;
			}
		}
	}
	
	
	"Thread group."
	variable InternalThreadGroup currentGroup = InternalThreadGroup();
	
	
	"Stops the current thread."
	shared void completeCurrent() => currentGroup.completeCurrent();
	
	"Executes `run` on separated thread belongs to this group.
	 Awaits completion no more then `timeoutMilliseconds` or unlimited if it is <= 0."
	shared Boolean execute (
		"Listener on uncaught exceptions." Anything( Thread, Throwable ) uncaughtExceptionListener,
		"Timeout in millieconds, <= 0 if unlimited." Integer timeoutMilliseconds,
		"Function to be executed on separated thread." Anything() run
	) {
		if ( currentGroup.groupInterrupted ) {
			currentGroup = InternalThreadGroup();
		}
		return currentGroup.execute( uncaughtExceptionListener, timeoutMilliseconds, run );
	}
	
}
