import ceylon.collection {
	HashMap,
	ArrayList
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration
}
import ceylon.test {
	TestDescription,
	TestResult,
	TestState,
	TestListener
}
import ceylon.test.annotation {
	TestExecutorAnnotation
}
import ceylon.test.engine.spi {
	TestExecutionContext
}

import java.lang {
	Runtime
}
import java.util.concurrent {
	CountDownLatch,
	Executors,
	ExecutorService
}
import ceylon.test.event {

	TestStartedEvent,
	TestFinishedEvent
}
import java.util.concurrent.locks {

	ReentrantLock
}


"Performs test initialization and execution."
by( "Lis" )
object asyncTestRunner {
	
	"initialized values"
	HashMap<FunctionDeclaration, InitStorage | VariantTestOutput> inits
			= HashMap<FunctionDeclaration, InitStorage | VariantTestOutput>(); 
	
	"sequentially executed tests"
	ArrayList<RunnableTestContext> sequentialTests = ArrayList<RunnableTestContext>();
	
	"concurrently executed tests"
	ArrayList<RunnableTestContext> concurrentTests = ArrayList<RunnableTestContext>();
	
	
	"Locks results filling."
	ReentrantLock fillLocker = ReentrantLock();
	
	
	"total number of tests"
	variable Integer testNumber = -1;
	
	"Cache async test executor declaration"
	ClassDeclaration asyncTestDeclaration = `class AsyncTestExecutor`;
	
	
	"performs initialization"
	InitStorage | VariantTestOutput runInitialization( FunctionDeclaration declaration ) {
		if ( exists ret = inits.get( declaration ) ) {
			return ret;
		}
		else {
			InitializerContext context = InitializerContext();
			value ret = context.run( declaration );
			inits.put( declaration, ret );
			return ret;
		}
	}
	
	"Evaluates test initialization and conditions."
	InitStorage | VariantTestOutput evaluateTestInits (
		FunctionDeclaration functionDeclaration, TestExecutionContext context
	) {
		value conditionsResult = evaluateAnnotatedConditions( functionDeclaration, context );
		if ( exists initAnn = annotationFromChain<InitAnnotation>( functionDeclaration ) ) {
			value inits = runInitialization( initAnn.initializer );
			switch ( inits )
			case ( is InitStorage ) {
				if ( nonempty conditionsResult ) { return VariantTestOutput( conditionsResult, 0 ); }
				else { return inits; }
			}
			case ( is VariantTestOutput ) {
				return VariantTestOutput( inits.outs.append( conditionsResult ), inits.totalElapsedTime );
			}
		}
		else if ( nonempty conditionsResult ) {
			return VariantTestOutput( conditionsResult, 0 );
		}
		else {
			return EmptyInitStorage();
		}
	}
	

	"Executes all previously added tests."
	void runTests() {
		// run concurrent tests firstly
		Integer totalConcurrent = concurrentTests.size;
		if ( totalConcurrent > 0 ) {
			if ( totalConcurrent == 1 ) {
				concurrentTests.first?.runTest();
			}
			else {
				CountDownLatch latch = CountDownLatch( totalConcurrent );
				ExecutorService executor = Executors.newFixedThreadPool( Runtime.runtime.availableProcessors() );
				for ( test in concurrentTests ) {
					executor.execute( ConcurrentTestRunner( test, latch ) );
				}
				latch.await();
			}
			concurrentTests.clear();
		}
		// run sequential tests
		for ( test in sequentialTests ) {
			test.runTest();
		}
		sequentialTests.clear();
		testNumber = -1;
		
		// dispose all initis
		value list = inits.items.narrow<InitStorage>();
		for ( con in list ) { con.dispose(); }
		inits.clear();
	}
	
	
	"Returns total number of test run using `AsyncTestContext` from the given desciptions."
	Integer numberOfAsyncTest( TestDescription* descriptions ) {
		variable Integer ret = 0;
		for ( descr in descriptions ) {
			if ( exists fDeclaration = descr.functionDeclaration, isAsyncExecutedTest( fDeclaration ) ) {
				ret ++;
			}
			ret += numberOfAsyncTest( *descr.children );
		}
		return ret;
	}
		
	
	"Adds test to be run lately. If this is last test the execution is started."
	shared void addTest (
		FunctionDeclaration functionDeclaration,
		ClassDeclaration? classDeclaration,
		TestExecutionContext parent,
		TestDescription description
	) {
		// calculates number of async tests
		if ( testNumber < 0 ) {
			testNumber = numberOfAsyncTest( parent.runner.description );
		}
		
		value inits = evaluateTestInits( functionDeclaration, parent );
		switch ( inits )
		case ( is InitStorage ) {
			// test will be executed
			value addedContext = DeferredTestContext( functionDeclaration, classDeclaration, parent, inits );
			// add test to appropriate list based on `alone` annotation
			if ( annotationFromChain<AloneAnnotation>( functionDeclaration ) exists ) {
				sequentialTests.add( addedContext );
			}
			else {
				concurrentTests.add( addedContext );
			}
		}
		case ( is VariantTestOutput ) {
			sequentialTests.add( CompletedTestContext( parent, description, inits ) );
		}
		
		// if it is last test - execute them
		if ( sequentialTests.size + concurrentTests.size == testNumber ) {
			runTests();
		}
	}
	
	
	"Fills results of the test to execution context. Here in order to avoind race conditions when filling to test runner."
	shared void fillTestResults (
		"Context to be filled with results." TestExecutionContext context,
		"Test results." TestOutput[] testOutputs,
		"Total test elapsed time." Integer runInterval
	) {
		testStartEvent( context );
		TestDescription runDescription = context.description;
		if ( nonempty testOutputs ) {
			variable Integer index = 0;
			for ( res in testOutputs ) {
				testVariantResultEvent( context, res, ++ index );
			}
			variable TestState state = testOutputs.first.state;
			for ( item in testOutputs.rest ) {
				if ( item.state > state ) { state = item.state; }
			}
			testFinishEvent (
				context,
				TestResult( runDescription, state, true, null, runInterval )
			);
		}
		else {
			testFinishEvent (
				context,
				TestResult( runDescription, TestState.success, false, null, runInterval )
			);
		}
		
	}
	
	"Fills test start event."
	shared void testStartEvent( "Context to be filled with results." TestExecutionContext context ) {
		fillLocker.lock();
		try {
			context.fire().testStarted( TestStartedEvent( context.description ) );
		}
		finally { fillLocker.unlock(); }
	}
	
	"Fills with test variant results"
	shared void testVariantResultEvent (
		"Context to be filled with results." TestExecutionContext context,
		"Test output to be filled as variant result." TestOutput testOutput,
		"Variant index." Integer index
	) {
		fillLocker.lock();
		try {
			TestDescription variant = context.description.forVariant( testOutput.title, index );
			TestExecutionContext child = context.childContext( variant );
			TestListener listener = child.fire();
			listener.testStarted( TestStartedEvent( variant ) );
			listener.testFinished( TestFinishedEvent(
				TestResult( variant, testOutput.state, false, testOutput.error, testOutput.elapsedTime )
			) );
		}
		finally { fillLocker.unlock(); }
	}
	
	"Fills with test finish event."
	shared void testFinishEvent (
		"Context to be filled with results." TestExecutionContext context,
		"Results of the test." TestResult testResult
	) {
		fillLocker.lock();
		try { context.fire().testFinished( TestFinishedEvent( testResult ) ); }
		finally { fillLocker.unlock(); }
	}

	
	"`true` if execution is performed using `AsyncTestExecutor`"
	Boolean isAsyncExecutedTest( FunctionDeclaration functionDeclaration ) {
		if ( exists exec = annotationFromChain<TestExecutorAnnotation>( functionDeclaration ) ) {
			return exec.executor == asyncTestDeclaration;
		}
		else {
			return false;
		}
	}
		
}
