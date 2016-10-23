import java.util.concurrent.atomic {
	AtomicBoolean
}
import java.util.concurrent.locks {
	ReentrantLock,
	Condition
}
import ceylon.test {

	TestState
}


"Performs initialization and stores initialized values."
since( "0.5.0" )
by( "Lis" )
class InitializerContext() satisfies AsyncInitContext
{
	
	"locks concurent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();

	
	"`true` if initialization completed"
	AtomicBoolean running = AtomicBoolean( true );
	
	"non-null if aborted"
	variable TestOutput? abortOuts = null;
	
	
	shared actual void abort( Throwable reason, String title ) {
		if ( running.compareAndSet( true, false ) ) {
			String msg = if ( title.empty ) then "initialization" else "initialization with ``title``";
			abortOuts = TestOutput( TestState.aborted, reason, 0, msg );
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	shared actual void proceed() {
		if ( running.compareAndSet( true, false ) ) {
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}

	
	"Runs initialization process. Returns error if occured"
	shared TestOutput? run( Anything(AsyncInitContext)[] inits ) {
		locker.lock();
		running.set( true );
		try {
			abortOuts = null;
			for ( init in inits ) {
				init( this );
				// await initialization completion
				if ( running.get() ) { condition.await(); }
				if ( exists ret = abortOuts ) { return ret; }
			}
			return null;
		}
		catch ( Throwable err ) {
			running.set( false );
			return TestOutput( TestState.aborted, err, 0, "initialization" );
		}
		finally {
			locker.unlock();
		}
	}
	
	
	shared actual String string {
		String compl = if ( running.get() ) then "running" else "completed";
		return "TestInitContext, status: '``compl``'";
	}
	
}




