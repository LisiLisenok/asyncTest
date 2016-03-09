import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.test {

	TestDescription,
	TestResult
}
import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration,
	OpenInterfaceType,
	Package
}
import ceylon.collection {

	LinkedList
}
import java.lang {

	Runtime
}
import java.util.concurrent {

	CountDownLatch,
	Executors,
	ExecutorService
}


"Posseses and executes grouped tests."
by( "Lis" )
class TestGroupExecutor (
	"Container the test is performed on." Package | ClassDeclaration container,
	"Emitting test results to." TestEventEmitter resultEmitter,
	"Context the group executed on." shared TestExecutionContext groupContext
) {
	
	"Test event emitter with results collection."
	TestResultCollector resultCollector = TestResultCollector( resultEmitter );
	
	"Description of execution to be done."
	class TestExecutionDescription(
		"Test function." shared FunctionDeclaration functionDeclaration,
		"Description of the test." shared TestDescription description
	) {}
	
	"Executions the group contains."
	LinkedList<TestExecutionDescription> executions = LinkedList<TestExecutionDescription>();

	
	"Instantiates a test container if `ClassDeclaration`."
	Object? instantiate() {
		if ( is ClassDeclaration c = container ) {
			return instantiateFromClassDeclaration( c );
		}
		else {
			return null;
		}
	}
	
	"`True` if package or module marked with `sequential`."
	Boolean isPackageOrModuleSequential( Package pac )
			=> pac.annotated<SequentialAnnotation>() || pac.container.annotated<SequentialAnnotation>();
	
	"`True` if the test to be performed in sequential order and `false` otherwise."
	Boolean isSequential() {
		switch ( container )
		case ( is Package ) {
			return isPackageOrModuleSequential( container );
		}
		case ( is ClassDeclaration ) {
			variable ClassDeclaration? exDecl = container;
			while ( exists decl = exDecl ) {
				if ( decl.annotated<SequentialAnnotation>() ) {
					return true;
				}
				exDecl = decl.extendedType?.declaration;
			}
			return isPackageOrModuleSequential( container.containingPackage );
		}
	}
	
	"Runs all test concurrently."
	void runConcurrently( Object? instance ) {
		Integer totalTests = executions.size;
		if ( totalTests > 1 ) {
			CountDownLatch latch = CountDownLatch( totalTests );
			ExecutorService executor = Executors.newFixedThreadPool( Runtime.runtime.availableProcessors() );
			for ( test in executions ) {
				executor.execute (
					ConcurrentTestRunner (
						AsyncTestProcessor (
							resultCollector,
							test.functionDeclaration,
							instance,
							groupContext,
							test.description
						),
						latch
					)
				);
			}
			latch.await();
			executor.shutdown();
		}
		else if ( exists first = executions.first ) {
			AsyncTestProcessor (
				resultCollector,
				first.functionDeclaration,
				instance,
				groupContext,
				first.description
			).runTest();
		}
	}
	
	"Runs all test sequentially."
	void runSequentially( Object? instance ) {
		for ( test in executions ) {
			AsyncTestProcessor (
				resultCollector,
				test.functionDeclaration,
				instance,
				groupContext,
				test.description
			).runTest();
		}
	}
	
	
	"Returns `true` if function runs async test == takes `AsyncTestContext` as first argument."
	Boolean isAsyncDeclaration( FunctionDeclaration functionDeclaration ) {
		if ( nonempty argDeclarations = functionDeclaration.parameterDeclarations,
			is OpenInterfaceType argType = argDeclarations.first.openType,
			argType.declaration == `interface AsyncTestContext`
		) {
			return true;
		}
		else {
			return false;
		}
	}
	
	
	"Returns `true` if test conditions are meet and `false` if test has to be skipped."
	Boolean evaluateConditions() {
		if ( nonempty conditions = evaluateContainerAnnotatedConditions( container, groupContext ) ) {
			// skip all tests
			skipGroupTest( conditions );
			return false;
		}
		else {
			return true;
		}
	}
	
	"Finalizes testing - raised test finish event and collects test results."
	TestSummary finalizeTest() {
		executions.clear();
		resultCollector.stopRecording();
		resultCollector.finishEvent (
			groupContext,
			TestResult (
				groupContext.description,
				resultCollector.overallState,
				true,
				null,
				resultCollector.overallTestTime
			),
			0
		);
		
		return TestSummary (
			resultCollector.overallState,
			resultCollector.successTotal,
			resultCollector.failureTotal,
			resultCollector.errorTotal,
			resultCollector.skipTotal,
			resultCollector.abortTotal,
			resultCollector.executionTotal,
			resultCollector.overallTestTime
		);
	}
	
	
	"Adds new test to the group."
	shared void addTest (
		FunctionDeclaration functionDeclaration,
		TestDescription description
	) {
		if ( isAsyncDeclaration( functionDeclaration ) ) {
			executions.add( TestExecutionDescription( functionDeclaration, description ) );
		}
		else {
			throw AssertionError (
				"Async test is performed with ``functionDeclaration`` which doesn't take first argument of `AsyncTestContext` type."
			);
		}
	}
	
	"Skips all tests in the group."
	shared TestSummary skipGroupTest( [TestOutput+] outputs ) {
		resultCollector.startRecording();
		resultCollector.startEvent( groupContext );
		for ( execution in executions ) {
			TestExecutionContext context = groupContext.childContext( execution.description );
			resultCollector.fillTestResults( context, outputs, 0, 0 );
		}
		
		return finalizeTest();
	}
	
	"Runs tests in this group."
	shared TestSummary run() {
		resultCollector.startRecording();
		resultCollector.startEvent( groupContext );
		
		if ( evaluateConditions() ) {
			Object? instance = instantiate();
			if ( is TestSuite instance ) {
				if ( exists ret = InitializerContext().run( instance ) ) {
					value testOuts = [ret];
					for ( test in executions ) {
						TestExecutionContext context = groupContext.childContext( test.description );
						resultCollector.fillTestResults( context, testOuts, 0, 0 );
					}
				}
				else {
					if ( isSequential() ) { runSequentially( instance ); }
					else { runConcurrently( instance ); }
				}
				instance.dispose();
			}
			else {
				if ( isSequential() ) { runSequentially( instance ); }
				else { runConcurrently( instance ); }
			}
		}
		
		return finalizeTest();
	}
	
}