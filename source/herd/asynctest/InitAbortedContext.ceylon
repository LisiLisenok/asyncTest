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


"Test context aborted by initialization."
by( "Lis" )
class InitAbortedContext(
	TestExecutionContext parent,
	TestDescription description,
	InitError inits
)
		satisfies RunnableTestContext
{
	
	shared actual void runTest() {
		TestExecutionContext context = parent.childContext( description );
		TestDescription runDescription = context.description;
		context.fire().testStarted( TestStartedEvent( runDescription ) );
		TestDescription variant = runDescription.forVariant( inits.title, 1 );
		TestExecutionContext child = context.childContext( variant );
		TestListener listener = child.fire();
		listener.testStarted( TestStartedEvent( variant ) );
		listener.testFinished( TestFinishedEvent(
			TestResult( variant, TestState.aborted, false, inits.reason, 0 )
		) );
		context.fire().testFinished (
			TestFinishedEvent( TestResult( runDescription, TestState.aborted, true, null ) )
		);
	}
	
}