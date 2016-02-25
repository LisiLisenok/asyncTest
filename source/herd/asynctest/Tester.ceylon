import ceylon.collection {

	ArrayList
}
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
import ceylon.language.meta.model {

	IncompatibleTypeException,
	InvocationException
}
import ceylon.test.engine {

	TestAbortedException,
	TestSkippedException
}


"performs a one test execution"
by( "Lis" )
class Tester( InitStorage inits ) satisfies AsyncTestContext
{
	
	"`true` if currently run"
	AtomicBoolean running = AtomicBoolean( false );
	"locker behind this running"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();

	
	ArrayList<TestOutput> output = ArrayList<TestOutput>();
	"tasks locking"
	ReentrantLock outputLocker = ReentrantLock();

	
	variable Integer startTime = 0;
	variable Integer completeTime = 0; 
	
	"total running interval, milliseconds"
	shared Integer runInterval => if ( completeTime > startTime ) then completeTime - startTime else 0;
	
	
	void addOutput(	TestState state, Throwable? error, String title, String preamble = "" ) {
		Integer elapsed = if ( startTime > 0 ) then system.milliseconds - startTime else 0;
		outputLocker.lock();
		try { output.add( TestOutput( state, error, elapsed, title, preamble ) ); }
		finally { outputLocker.unlock(); }
	}
	
	
	shared actual void start() {
		if ( running.get() ) {
			startTime = system.milliseconds;
			completeTime = startTime;
		}
	}
	
	shared actual void complete( String title ) {
		if ( running.compareAndSet( true, false ) ) {
			if ( output.empty && !title.empty ) { addOutput( TestState.success, null, title ); }
			completeTime = system.milliseconds;
			if ( startTime == 0 ) { startTime = completeTime; }
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}


	shared actual Item? get<Item>( String name ) => inits.retrieve<Item>( name );
	
	shared actual Item[] getAll<Item>() => inits.retrieveAll<Item>();

	
	shared actual void assertTrue( Boolean condition, String message, String title ) {
		if ( running.get() && !condition ) {
			addOutput( TestState.failure, AssertionError( message ), title );
		}
	}
	
	shared actual void assertFalse( Boolean condition, String message, String title ) {
		if ( running.get() && condition ) {
			addOutput( TestState.failure, AssertionError( message ), title );
		}
	}
	
	shared actual void assertNull( Anything val, String message, String title ) {
		if ( running.get() && val exists ) {
			addOutput( TestState.failure, AssertionError( message ), title );
		}
	}
	
	shared actual void assertNotNull( Anything val, String message, String title ) {
		if ( running.get() && !val exists ) {
			addOutput( TestState.failure, AssertionError( message ), title );
		}
	}

	
	shared actual void fail( Throwable reason, String title ) {
		if ( running.get() ) {
			if ( is AssertionError reason ) {
				addOutput( TestState.failure, reason, title );
			}
			else {
				addOutput( TestState.error, reason, title );
			}
		}
	}
	
	shared actual void abort( Throwable? reason, String title ) {
		if ( running.get() ) { addOutput( TestState.aborted, reason, title ); }
	}
	
	
	"Returns output from the test"
	shared TestOutput[] run( Anything(AsyncTestContext) tested ) {
		if ( running.compareAndSet( false, true ) ) {
			locker.lock();
			try {
				tested( this );
				if ( running.get() ) { condition.await(); }
			}
			catch ( Throwable err ) {
				if ( err is TestSkippedException ) {
					addOutput( TestState.skipped, err, "skipped with exception" );
				}
				else if ( err is TestAbortedException ) {
					abort( err, "aborted with exception" );
				}
				else if  ( err is IncompatibleTypeException | InvocationException ) {
					abort( err, "incompatible invocation" );
				}
				else {
					fail( err, "failed with exception" );
				}
				complete();
			}
			finally {
				locker.unlock();
			}
			
			outputLocker.lock();
			try {
				value ret = output.sequence();
				output.clear();
				return ret;
			}
			finally { outputLocker.unlock(); }
		}
		else {
			return [];
		}
	}	
	
}
