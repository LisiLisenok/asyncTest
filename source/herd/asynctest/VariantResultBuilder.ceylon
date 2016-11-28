import ceylon.test {
	TestState
}
import ceylon.collection {
	ArrayList
}
import ceylon.test.engine {
	TestSkippedException,
	TestAbortedException
}


"Builds test variant result from several test outputs."
see( `class TestVariantResult`, `class TestOutput` )
since( "0.6.0" ) by( "Lis" )
shared class VariantResultBuilder() {
	variable Integer startTime = system.nanoseconds;
	variable TestState overallState = TestState.skipped;
	ArrayList<TestOutput> outs = ArrayList<TestOutput>(); 
	
	"Starts building from scratch."
	shared void start() {
		startTime = system.nanoseconds;
		overallState = TestState.skipped;
		outs.clear();
	}
	
	"Adds test output to the variant result."
	shared void addOutput( TestOutput output ) {
		outs.add( output );
		if ( overallState < output.state ) {
			overallState = output.state;
		}
	}
	
	"Adds test failure report to the test results."
	shared void addFailure( Throwable reason, String title = "" ) {
		TestState state;
		if ( is AssertionError reason ) {
			state = TestState.failure;
		}
		else if ( is TestSkippedException reason ) {
			state = TestState.skipped;
		}
		else if ( is TestAbortedException reason ) {
			state = TestState.aborted;
		}
		else {
			state = TestState.error;
		}
		addOutput( TestOutput( state, reason, ( system.nanoseconds - startTime ) / 1000000, title ) );
	}
	
	"Adds test success report to the test results."
	shared void addSuccess( String title ) {
		addOutput( TestOutput( TestState.success, null, ( system.nanoseconds - startTime ) / 1000000, title ) );
	}
	
	
	"Returns built test variant results."
	shared TestVariantResult variantResult {
		TestState state = if ( outs.empty ) then TestState.success else overallState;
		return TestVariantResult( outs.sequence(), ( system.nanoseconds - startTime ) / 1000000, state );
	}
}
