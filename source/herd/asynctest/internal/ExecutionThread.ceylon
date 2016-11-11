import java.lang {
	Thread,
	ThreadGroup,
	InterruptedException
}
import java.util.concurrent.locks {
	Condition,
	ReentrantLock
}


"Thread which may be reused.
 Used internally by [[ContextThreadGroup]]."
since( "0.6.0" ) by( "Lis" )
class ReusableThread( ThreadGroup group, String name )
		extends Thread( group, name )
{
	ReentrantLock executeLock = ReentrantLock();
	Condition executeCondition = executeLock.newCondition();
	
	AtomicBoolean running = AtomicBoolean( true );
	
	
	variable Anything()? toBeExecuted = null;
	variable LatchWaiter latch = LatchWaiter( 1 );
	
	"Executes the given function. Returnes latch to await execution.
	 Be carefull - not run with `completed` and await returned `latch` before executing next."
	shared LatchWaiter execute( Anything() toExecute ) {
		executeLock.lock();
		try {
			toBeExecuted = toExecute;
			latch = LatchWaiter( 1 );
			executeCondition.signal();
			return latch;
		}
		finally { executeLock.unlock(); }
	}
	
	"Stops thecurrent thread."
	shared void complete() {
		running.set( false );
		executeLock.lock();
		try { executeCondition.signal(); }
		finally { executeLock.unlock(); }
	}
	
	
	shared actual void run() {
		while ( running.get() ) {
			executeLock.lock();
			try {
				if ( exists f = toBeExecuted ) {
					f();
					latch.countDown();
				}
				executeCondition.await();
			}
			catch ( InterruptedException err ) {
				// this means condition awaited completion has been interrupted
				// TODO: log - ?
			}
			finally {
				executeLock.unlock();
			}
		}
	}
}
