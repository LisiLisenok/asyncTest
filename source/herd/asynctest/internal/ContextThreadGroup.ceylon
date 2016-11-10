import java.util.concurrent.atomic {
	AtomicReference
}
import java.lang {
	Thread,
	ThreadDeath,
	ThreadGroup,
	SecurityException,
	InterruptedException
}


since( "0.6.0" ) by( "Lis" )
shared abstract class ContextThreadGroup<Context>( String title ) extends ThreadGroup( title )
{
	AtomicReference<Context?> context = AtomicReference<Context?>( null );
	
	shared actual void uncaughtException( Thread t, Throwable e ) {
		if ( is ThreadDeath e ) {
			super.uncaughtException( t, e );
		}
		else {
			if ( exists c = context.getAndSet( null ) ) {
				stopWithError( c, e );
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
		// interrupt may cause security exception - we may do nothing with
		try { interrupt(); }
		catch ( SecurityException err ) {
			// TODO: log - ?
		}
	}
	
	"Stops the context with the given error."
	shared formal void stopWithError( Context c, Throwable err );
	
	
	"Executes `run` on separated thread belongs to this group.
	 Awaits completion no more then `timeoutMilliseconds` or unlimited if it is <= 0."
	shared Boolean execute( Context c, Integer timeoutMilliseconds, Anything() run ) {
		LatchWaiter latch = LatchWaiter( 1 );
		while ( !context.compareAndSet( context.get(), c ) ) {}
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
