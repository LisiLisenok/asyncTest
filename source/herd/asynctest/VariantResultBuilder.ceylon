import ceylon.test {
	TestState
}
import ceylon.collection {
	ArrayList
}


"Builds test variant result from several test outputs."
see( `class TestVariantResult`, `class TestOutput` )
since( "0.6.0" ) by( "Lis" )
shared class VariantResultBuilder() {
	variable Integer startTime = system.milliseconds;
	variable TestState overallState = TestState.skipped;
	ArrayList<TestOutput> outs = ArrayList<TestOutput>(); 
	
	"Starts building from scratch."
	shared void start() {
		startTime = system.milliseconds;
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
		TestState state = if ( is AssertionError reason ) then TestState.failure else TestState.error; 
		addOutput( TestOutput( state, reason, system.milliseconds - startTime, title ) );
	}
	
	"Adds test success report to the test results."
	shared void addSuccess( String title ) {
		addOutput( TestOutput( TestState.success, null, system.milliseconds - startTime, title ) );
	}
	
	
	shared TestVariantResult variantResult {
		TestState state = if ( outs.empty ) then TestState.success else overallState;
		return TestVariantResult( outs.sequence(), system.milliseconds - startTime, state );
	}
}
