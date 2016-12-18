import ceylon.collection {
	HashMap
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
	Package
}
import ceylon.test {
	TestDescription
}
import ceylon.test.engine.spi {
	TestExecutionContext
}
import java.util.concurrent {

	CountDownLatch,
	Executors,
	ExecutorService,
	ThreadFactory
}
import java.lang {

	Runtime,
	Thread,
	Runnable
}
import java.util.concurrent.locks {

	ReentrantLock
}
import herd.asynctest.internal {
	findFirstAnnotation,
	declarationVerifier
}


"Combines tests in the suites and starts test executions."
since( "0.0.1" ) by( "Lis" )
object asyncTestRunner {
	
	"Executors of test groups - package or class level."
	HashMap<String, TestGroupExecutor> sequentialExecutors = HashMap<String, TestGroupExecutor>(); 
	HashMap<String, TestGroupExecutor> concurrentExecutors = HashMap<String, TestGroupExecutor>(); 
	
	"Since `ceylon.test` uses socket to IDE which is not thread safe,
	 this lock is neccessary in order to syncronize writing test results to test framework (i.e. socket)."
	ReentrantLock resultWriteLock = ReentrantLock();
	
	
	"total number of tests"
	variable small Integer totalTestNumber = -1;
	
	"number of added tests"
	variable small Integer addedTestNumber = 0;
	
	
	"Returns total number of test run using `AsyncTestContext` from the given descriptions."
	small Integer numberOfAsyncTest( TestDescription* descriptions ) {
		variable small Integer ret = 0;
		for ( descr in descriptions ) {
			if ( exists fDeclaration = descr.functionDeclaration, declarationVerifier.isAsyncExecutedTest( fDeclaration ) ) {
				ret ++;
			}
			ret += numberOfAsyncTest( *descr.children );
		}
		return ret;
	}
	
	"Returns registered test executor for the given container or creates new one."
	TestGroupExecutor getTestExecutor (
		"Group the executor is looked for." ClassDeclaration | Package container,
		"Context the group executed on." TestExecutionContext groupContext
	) {
		if ( exists groupExecutor = sequentialExecutors.get( container.qualifiedName ) ) {
			return groupExecutor;
		}
		else if ( exists groupExecutor = concurrentExecutors.get( container.qualifiedName ) ) {
			return groupExecutor;
		}
		else {
			// create new executor and push it to concurrent or sequential group depending on 'concurrent' annotation
			TestGroupExecutor groupExecutor = TestGroupExecutor( container, groupContext, resultWriteLock );
			if ( findFirstAnnotation<ConcurrentAnnotation>( container ) exists ) {
				concurrentExecutors.put( container.qualifiedName, groupExecutor );
			}
			else {
				sequentialExecutors.put( container.qualifiedName, groupExecutor );
			}
			return groupExecutor;
		}
	}


	"Executes tests from 'concurrent' group using thread pool."
	void executeConcurrentTest( Integer totalCores ) {
		// Thread pool used in concurrent mode
		variable Integer threadIndex = 0;
		ExecutorService pool = Executors.newFixedThreadPool (
			totalCores, // pool size
			// factory just in order to see 'good' names of the used threads
			//( Runnable runnable ) => Thread( runnable, "async test pool - thread ``++threadIndex``" )
			//old style - for doc tool while #6749 issue not solved
			object satisfies ThreadFactory {
				shared actual Thread newThread( Runnable runnable )
						=> Thread( runnable, "async test pool - thread ``++threadIndex``" );
			}
		);
		try {
			// run concurrent executors
			CountDownLatch latch = CountDownLatch( concurrentExecutors.size );
			for ( executor in concurrentExecutors.items ) {
				pool.execute( ConcurrentGroupExecutor( executor, latch ) );
			}
			// await completion
			latch.await();
		}
		finally {
			// always shutdown the pool!
			pool.shutdown();
		}
	}
	
	
	"Adds test to be run lately. If this is the last test then the execution is started."
	shared void addTest (
		FunctionDeclaration functionDeclaration,
		ClassDeclaration? classDeclaration,
		TestExecutionContext parent,
		TestDescription description
	) {		
		// calculates number of async tests
		if ( totalTestNumber < 0 ) {
			totalTestNumber = numberOfAsyncTest( parent.runner.description );
		}
		
		// add test
		getTestExecutor( classDeclaration else functionDeclaration.containingPackage, parent )
				.addTest( description );
		addedTestNumber ++;
		// if it is last test - execute all tests
		if ( addedTestNumber == totalTestNumber ) {
			Integer totalCores = Runtime.runtime.availableProcessors();
			if ( totalCores > 1 ) {
				// run concurrent executors
				executeConcurrentTest( totalCores );
				// run sequential executors
				for ( executor in sequentialExecutors.items ) {
					executor.runTest();
				}
			}
			else {
				// run concurrent executors sequentially since just a one core is available
				for ( executor in concurrentExecutors.items ) {
					executor.runTest();
				}
				// run sequential executors
				for ( executor in sequentialExecutors.items ) {
					executor.runTest();
				}
			}
		}
	}
	
}
