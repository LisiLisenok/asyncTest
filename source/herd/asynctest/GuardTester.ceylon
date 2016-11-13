import herd.asynctest.internal {
	ContextThreadGroup
}
import java.lang {
	Thread
}


"The most lower level of the runners - invokes test function itself.  
 Guards from reporting when completed or interrupted.
 
 Rule: one test function one guard tester.
 "
since( "0.6.0" ) by( "Lis" )
class GuardTester (
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group,
	"Function to be executed."
	TestFunction testFunction,
	"Context the test function to be executed on."
	AsyncTestContext context
)
		extends ContextBase() satisfies AsyncTestContext
{	
	
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
			context.complete( title );
			signal();
		}
	}
	
	shared actual void fail( Throwable|Anything() exceptionSource, String title ) {
		if ( running.get() ) {
			context.fail( exceptionSource, title );
		}
	}
	
	shared actual void succeed( String message ) {
		if ( running.get() ) {
			context.succeed( message );
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
				else "time out of ``testFunction.functionTitle`` execution"
			);
			complete();
		}
	}
	
}
