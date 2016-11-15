import herd.asynctest.internal {
	ContextThreadGroup
}
import java.lang {
	Thread
}
import java.util.concurrent.locks {
	ReentrantLock
}


"The most lower level of the runners - invokes test function itself.  
 Guards from reporting when completed or interrupted.
 
 Rule: one test function run one guard tester. Since guard may interrupt test thread on timeout - but there is no quarantee
 the threads are actually interrupted and will not put messages to guard (which is test context listens test messages).  
 "
since( "0.6.0" ) by( "Lis" )
class GuardTester (
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group,
	"Function to be executed."
	TestFunction testFunction,
	"Context the test function to be executed on."
	AsyncMessageContext context
)
		extends ContextBase() satisfies AsyncTestContext
{	
	
	"Callbacks locking."
	ReentrantLock locker = ReentrantLock();
	
	
	"Fails and completes the test with uncaught exception from some execution thread."
	void failWithUncaughtException( Thread t, Throwable e ) {
		fail( e, "uncaught exception in child thread." );
		complete();
	}

	"Runs test function."
	void runTestFunction() {
		try {
			// invoke test function
			testFunction.run( this );
		}
		catch ( Throwable err ) {
			fail (
				err, if ( testFunction.functionTitle.empty ) then ""
					else  "``testFunction.functionTitle`` failed with exception" );
			complete();
		}
		// await test completion
		await();
	}
	
	shared actual void complete( String title ) {
		if ( running.compareAndSet( true, false ) ) {
			locker.lock();
			try { context.complete( title ); }
			finally { locker.unlock(); }
			signal();
		}
	}
	
	shared actual void fail( Throwable|Anything() exceptionSource, String title ) {
		if ( running.get() ) {
			locker.lock();
			try { context.fail( exceptionSource, title ); }
			finally { locker.unlock(); }
		}
	}
	
	shared actual void succeed( String message ) {
		if ( running.get() ) {
			locker.lock();
			try { context.succeed( message ); }
			finally { locker.unlock(); }
		}
	}
	
	
	"Executes the given test function with the given test context."
	shared void execute() {
		if ( !group.execute( failWithUncaughtException, testFunction.timeOutMilliseconds, runTestFunction ) ) {
			// timeout!
			value excep = TimeOutException( testFunction.timeOutMilliseconds );
			fail (
				excep,
				if ( testFunction.functionTitle.empty ) then excep.message
				else "time out of ```testFunction.functionTitle``` execution"
			);
			complete();
		}
	}
	
}
