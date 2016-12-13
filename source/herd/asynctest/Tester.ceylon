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

	AsyncTestRunner,
	AsyncRunnerContext
}
import java.util.concurrent.locks {

	ReentrantLock
}


"* Performs a one test execution (test function + statements).  
 * Provides test function with test context.  
 * Collects test report.  
 
 Uses [[GuardTester]] for each function or statement run.  
 "
since( "0.0.1" ) by( "Lis" )
class Tester (
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group
)
		satisfies AsyncRunnerContext
{
	
	"Synchronizes output writing."
	ReentrantLock locker = ReentrantLock();
	
	"storage for reports"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	// Time is in nanoseconds!
	variable Integer startTime = 0;
	variable TestState totalState = TestState.skipped;

	"Test function + statements which are executed after the test function."
	variable TestFunction[] testFunctions = [];
	
		
	shared actual void complete( String title ) {
		if ( outputs.empty ) {
			if ( title.empty ) {
				locker.lock();
				try { totalState = TestState.success; }
				finally { locker.unlock(); }
			}
			else { addOutput( TestState.success, null, title ); }
		}
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
		locker.lock();
		try {
			outputs.add( TestOutput( state, error, ( system.nanoseconds - startTime ) / 1000000, title ) );
			if ( totalState < state ) { totalState = state; }
		}
		finally {
			locker.unlock();
		}
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
	
	
	"Runs all test functions using guard context."
	see( `class GuardTester` )
	void runWithGuard( AsyncRunnerContext context ) {
		// new GuardTest has to be used for each run
		for ( statement in testFunctions ) {
			GuardTester guard = GuardTester( group, statement, context );
			guard.execute();
		}
	}

	"Runs the test and returns output from the test."
	shared TestVariantResult run (
		"Test function." TestFunction testFunction,
		"Test statements which are executed after the test function." TestFunction[] statements,
		"Information on the currently run variant." TestInfo info,
		"Optional runner to run test function with." AsyncTestRunner? runner = null
	) {
		// make a clean tester
		outputs.clear();
		startTime = system.nanoseconds;
		
		// execute test function
		testFunctions = [testFunction];
		if ( exists runner ) {
			runner.run( this, runWithGuard, info );
		}
		else {
			runWithGuard( this );
		}
		// execute statements without runner since it is applied only to test function!
		if ( !statements.empty ) {
			testFunctions = statements;
			runWithGuard( this );
		}
		testFunctions = [];
		complete();  // completes if something wrong and no completion has been done by runner
		
		// return results
		value ret = outputs.sequence();
		outputs.clear();
		return TestVariantResult( ret, ( system.nanoseconds - startTime ) / 1000000, totalState );
	}
	
}
