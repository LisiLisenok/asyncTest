import herd.asynctest {
	AsyncTestContext
}
import java.util.concurrent.locks {
	Condition,
	ReentrantLock
}
import java.util.concurrent.atomic {
	AtomicBoolean
}
import herd.asynctest.internal {
	CurrentThread
}


"Provides in chain calls of the given test functions."
since( "0.7.0" ) by( "Lis" )
class ChainedTestContext (
	"Context to delegate reports." AsyncTestContext context,
	"The functions to be executed." Iterator<Anything(AsyncTestContext)> functions ) {
	
	"Notify to run next function."
	ReentrantLock locker = ReentrantLock();
	Condition completed = locker.newCondition();
	
	
	"Boxing the context in order to restrict functions callbacks to completed context."
	class TestContextBox() satisfies AsyncTestContext {
		AtomicBoolean runningAtomic = AtomicBoolean( true );
		shared Boolean running => runningAtomic.get();
		
		shared actual void complete( String title ) {
			if ( runningAtomic.compareAndSet( true, false ) ) {
				locker.lock();
				try { completed.signal(); }
				finally { locker.unlock(); }
			}
		}
		
		shared actual void fail( Throwable|Anything() exceptionSource, String title ) {
			if ( running ) { context.fail( exceptionSource, title ); }
		}
		
		shared actual void succeed( String message ) {
			if ( running ) { context.succeed( message ); }
		}
	}
	
	
	void processFunctions() {
		while ( is Anything(AsyncTestContext) f = functions.next(), CurrentThread.alive ) {
			// execute next chained function
			value box = TestContextBox();
			try { f( box ); }
			catch ( Throwable err ) {
				box.fail( err );
				box.complete();
			}
			if ( box.running ) {
				// await completion
				if ( locker.tryLock() ) {
					try { completed.await(); }
					finally { locker.unlock(); }
				}
			}
		}
	}
	
	
	"Processes the functions execution."
	shared void process() {
		processFunctions();
		context.complete();
	}
	
}
