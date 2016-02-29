import ceylon.test {

	TestResult,
	TestState,
	TestListener,
	TestDescription
}
import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.test.event {

	TestStartedEvent,
	TestFinishedEvent
}


"Fills results of the test to execution context."
by( "Lis" )
void fillTestResults (
	"Context to be filled with results." TestExecutionContext context,
	"Test results." TestOutput[] results,
	"Total test elapsed time." Integer runInterval
) {
	TestDescription runDescription = context.description;
	context.fire().testStarted( TestStartedEvent( runDescription ) );
	if ( nonempty results ) {
		variable Integer index = 0;
		for ( res in results ) {
			String str = if ( res.title.empty ) then res.state.string else res.state.string + ": " + res.title;
			String title = if ( res.prefix.empty ) then str else res.prefix + " - " + str;
			TestDescription variant = runDescription.forVariant( title, ++ index );
			TestExecutionContext child = context.childContext( variant );
			TestListener listener = child.fire();
			listener.testStarted( TestStartedEvent( variant ) );
			listener.testFinished( TestFinishedEvent(
				TestResult( variant, res.state, false, res.error, res.elapsedTime )
			) );
		}
		variable TestState state = results.first.state;
		for ( item in results.rest ) {
			if ( item.state > state ) { state = item.state; }
		}
		context.fire().testFinished (
			TestFinishedEvent( TestResult( runDescription, state, true, null, runInterval ) )
		);
	}
	else {
		context.fire().testFinished (
			TestFinishedEvent( TestResult( runDescription, TestState.success, false, null, runInterval ) )
		);
	}
}
