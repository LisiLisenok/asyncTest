import ceylon.test {

	TestResult,
	TestState
}
import ceylon.test.engine.spi {

	TestExecutionContext
}
import java.util.concurrent.atomic {

	AtomicReference,
	AtomicLong
}


"Test events emitter which collects results and redirects emission to another emitter."
since( "0.0.1" )
by( "Lis" )
class TestResultCollector( "Redirected emitter." TestEventEmitter emitter ) satisfies TestEventEmitter
{
	
	variable Integer startTime = 0;
	variable Integer endTime = 0;
	
	AtomicReference<TestState> totalState = AtomicReference<TestState>( TestState.skipped );
	
	AtomicLong successCount = AtomicLong( 0 );
	AtomicLong failureCount = AtomicLong( 0 );
	AtomicLong errorCount = AtomicLong( 0 );
	AtomicLong skipCount = AtomicLong( 0 );
	AtomicLong abortCount = AtomicLong( 0 );
	AtomicLong executionCount = AtomicLong( 0 );

	
	"The worst state from the all test results."
	shared TestState overallState => totalState.get();
	
	"Overall number of success events."
	shared Integer successTotal => successCount.get();
	
	"Overall number of failure events."
	shared Integer failureTotal => failureCount.get();
	
	"Overall number of error events."
	shared Integer errorTotal => errorCount.get();
	
	"Overall number of skip events."
	shared Integer skipTotal => skipCount.get();
	
	"Overall number of abort events."
	shared Integer abortTotal => abortCount.get();
	
	"Overall number of executions."
	shared Integer executionTotal => executionCount.get();
	
	
	"Overall time elapsed for test execution in milliseconds."
	see( `function startRecording`, `function stopRecording` )
	shared Integer overallTestTime => endTime - startTime;
	
	
	"Applies test state results to counters."
	void applyTestState( TestState state ) {
		while ( totalState.get() < state ) {
			totalState.set( state );
		}
		switch ( state )
		case ( TestState.success ) { successCount.incrementAndGet(); }
		case ( TestState.failure ) { failureCount.incrementAndGet(); }
		case ( TestState.error ) { errorCount.incrementAndGet(); }
		case ( TestState.skipped ) { skipCount.incrementAndGet(); }
		case ( TestState.aborted ) { abortCount.incrementAndGet(); }
	}
	
	
	shared actual void finishEvent( TestExecutionContext context, TestResult testResult, Integer executions ) {
		applyTestState( testResult.state );
		executionCount.getAndAdd( executions );
		emitter.finishEvent( context, testResult, executions );
	}
	
	shared actual void startEvent( TestExecutionContext context ) => emitter.startEvent( context );
	
	shared actual void variantResultEvent( TestExecutionContext context, TestOutput testOutput, Integer index ) {
		applyTestState( testOutput.state );
		emitter.variantResultEvent( context, testOutput, index );
	}
	
	
	"Starts recording - records start time."
	see( `function stopRecording`, `value overallTestTime` )
	shared void startRecording() => startTime = system.milliseconds;
	
	"Stops recording - records stop time."
	see( `function startRecording`, `value overallTestTime` )
	shared void stopRecording() => endTime = system.milliseconds;
}
