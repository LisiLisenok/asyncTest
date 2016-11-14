import ceylon.collection {
	ArrayList
}
import ceylon.language.meta.model {
	IncompatibleTypeException,
	InvocationException
}
import ceylon.test {
	TestState
}
import ceylon.test.engine {
	TestAbortedException,
	TestSkippedException
}
import herd.asynctest.internal {

	ContextThreadGroup
}
import herd.asynctest.runner {

	AsyncTestRunner
}


"* Performs a one test execution.  
 * Provides test function with test context.  
 * Collects test report.  
 
 Rule: a one test function a one tester.
 "
since( "0.0.1" ) by( "Lis" )
class Tester (
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group,
	"Function to be tested."
	TestFunction testFunction,
	"Information on the currently run variant."
	TestInfo info
)
		satisfies AsyncMessageContext
{
	"storage for reports"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	variable Integer startTime = 0;
	variable Integer completeTime = 0; 
	variable TestState totalState = TestState.skipped;
	
		
	shared actual void complete( String title ) {
		if ( outputs.empty ) {
			if ( title.empty ) { totalState = TestState.success; }
			else { addOutput( TestState.success, null, title ); }
		}
		completeTime = system.milliseconds;
		if ( startTime == 0 ) { startTime = completeTime; }
	}
		
	shared actual void fail( Throwable|Anything() exceptionSource, String title ) {
		if ( is Throwable exceptionSource ) {
			failWithError( exceptionSource, title );
		}
		else {
			try { exceptionSource(); }
			catch ( Throwable err ) { failWithError( err, title ); }
		}
	}
	
	shared actual void succeed( String message ) {
		addOutput( TestState.success, null, message );
	}
	
	
	"Adds new output to `outputs`"
	void addOutput( TestState state, Throwable? error, String title ) {
		Integer elapsed = if ( startTime > 0 ) then system.milliseconds - startTime else 0;
		outputs.add( TestOutput( state, error, elapsed, title ) );
		if ( totalState < state ) { totalState = state; }
	}
	
	"Fails the test with either `Exception` or `AssertionError`."
	void failWithError( Throwable reason, String title ) {
		if ( is AssertionError reason ) {
			addOutput( TestState.failure, reason, title );
		}
		else {
			if ( reason is TestSkippedException ) {
				addOutput( TestState.skipped, reason, if ( title.empty ) then "skipped with exception" else title );
			}
			else if ( reason is TestAbortedException ) {
				addOutput( TestState.aborted, reason, if ( title.empty ) then "aborted with exception" else title );
			}
			else if ( reason is IncompatibleTypeException | InvocationException ) {
				addOutput( TestState.aborted, reason, if ( title.empty ) then "incompatible invocation" else title );
			}
			else {
				addOutput( TestState.error, reason, title );
			}
		}
	}
	
	
	"Runs test function using guard context."
	see( `class GuardTester` )
	void runWithGuard( AsyncMessageContext context ) {
		GuardTester guard = GuardTester( group, testFunction, context );
		guard.execute();
	}

	"Returns output from the test."
	shared TestVariantResult run( AsyncTestRunner? runner = null ) {
		// execute test function
		startTime = system.milliseconds;
		completeTime = startTime;
		if ( exists runner ) {
			runner.run( this, runWithGuard, info );
		}
		else {
			runWithGuard( this );
		}
		complete();  // completes if something wrong and no completion has been done by runner
		
		// return results
		value ret = outputs.sequence();
		outputs.clear();
		return TestVariantResult( ret, completeTime - startTime, totalState );
	}
	
}
