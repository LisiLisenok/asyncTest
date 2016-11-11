import java.lang {
	Thread,
	ThreadDeath,
	ThreadGroup,
	SecurityException,
	InterruptedException
}
import java.util.concurrent.locks {
	ReentrantLock
}


"Represent group of the context - run main function listens uncaught exceptions and interrupt all threads."
since( "0.6.0" ) by( "Lis" )
shared class ContextThreadGroup( String title ) extends ThreadGroup( title )
{
	ReentrantLock litenerLock = ReentrantLock();
	variable Anything( Thread, Throwable )? uncaughtExceptionListener = null;
	
	shared actual void uncaughtException( Thread t, Throwable e ) {
		if ( is ThreadDeath e ) {
			super.uncaughtException( t, e );
		}
		else {
			litenerLock.lock();
			try {
				if ( exists listener = uncaughtExceptionListener ) {
					listener( t, e );
					interruptAllThreads();
				}
				else {
					// TODO: log - ?
					//super.uncaughtException( t, e );
				}
			}
			finally { litenerLock.unlock(); }
		}
	}

	"Interrupts all threads belong to the group like `ThreadGroup.interrupt` but doesn't throw."
	void interruptAllThreads() {
		// interrupt may cause security exception - we may do nothing with
		try { interrupt(); }
		catch ( SecurityException err ) {
			// TODO: log - ?
		}
	}

	
	
	"Executes `run` on separated thread belongs to this group.
	 Awaits completion no more then `timeoutMilliseconds` or unlimited if it is <= 0."
	shared Boolean execute (
		"Listener on uncaught exceptions." Anything( Thread, Throwable ) uncaughtExceptionListener,
		"Timeout in millieconds, <= 0 if unlimited." Integer timeoutMilliseconds,
		"Function to be executed on separated thread." Anything() run
	) {
		litenerLock.lock();
		this.uncaughtExceptionListener = uncaughtExceptionListener;
		litenerLock.unlock();
		LatchWaiter latch = LatchWaiter( 1 );
		// execute in eparated thread
		ExecutionThread thr = ExecutionThread ( this, title,
			() {
				try { run(); }
				catch ( InterruptedException err ) {
					// this means condition awaited completion has been interrupted
					// TODO: log - ?
				}
				finally { latch.countDown(); }
			}
		);
		thr.start();
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
