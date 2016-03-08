import java.util.concurrent.locks {

	ReentrantLock
}
import ceylon.test {

	TestResult,
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


"Emits results to the context using locked to provide synchronization."
by( "Lis" )
class GeneralEventEmitter() satisfies TestEventEmitter {
	
	"Locks results emitting."
	ReentrantLock emitterLocker = ReentrantLock();
	

	shared actual void startEvent( TestExecutionContext context ) {
		emitterLocker.lock();
		try {
			context.fire().testStarted( TestStartedEvent( context.description ) );
		}
		finally { emitterLocker.unlock(); }
	}
	
	shared actual void variantResultEvent (
		TestExecutionContext context,
		TestOutput testOutput,
		Integer index
	) {
		emitterLocker.lock();
		try {
			TestDescription variant = context.description.forVariant( testOutput.title, index );
			TestExecutionContext child = context.childContext( variant );
			TestListener listener = child.fire();
			listener.testStarted( TestStartedEvent( variant ) );
			listener.testFinished( TestFinishedEvent(
				TestResult( variant, testOutput.state, false, testOutput.error, testOutput.elapsedTime )
			) );
		}
		finally { emitterLocker.unlock(); }
	}
	
	shared actual void finishEvent (
		TestExecutionContext context,
		TestResult testResult,
		Integer executions
	) {
		emitterLocker.lock();
		try { context.fire().testFinished( TestFinishedEvent( testResult ) ); }
		finally { emitterLocker.unlock(); }
	}
	
}