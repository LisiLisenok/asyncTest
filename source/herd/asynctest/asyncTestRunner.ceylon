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
import ceylon.test.annotation {
	TestExecutorAnnotation
}
import ceylon.test.engine.spi {
	TestExecutionContext
}


"Performs test initialization and execution."
by( "Lis" )
object asyncTestRunner {
		
	"Emitting results of the test."
	GeneralEventEmitter resultEmitter = GeneralEventEmitter();
		
	"Test runner for a given maintainer declaration."
	HashMap<ClassDeclaration, TestRunner> runners = HashMap<ClassDeclaration, TestRunner>();
	
	"Test runner used if maintainer is not specified."
	UnmaintainedTestRunner defaultRunner = UnmaintainedTestRunner( resultEmitter );
	
	
	"total number of tests"
	variable Integer totalTestNumber = -1;
	
	"number of added tests"
	variable Integer addedTestNumber = 0;
	
	"Cache async test executor declaration"
	ClassDeclaration asyncTestDeclaration = `class AsyncTestExecutor`;
	
	
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
	
	
	"Returns runner corresponding to the given module or creates new one."
	TestRunner getRunner( Package container ) {
		if ( exists decl = maintainerDeclaration( container ) ) {
			if ( exists ret = runners.get( decl ) ) {
				return ret;
			}
			else if ( is TestMaintainer maintainer = instantiateFromClassDeclaration( decl ) ){
				MaintainedTestRunner runner = MaintainedTestRunner( maintainer, resultEmitter );
				runners.put( decl, runner );
				return runner;
			}
			else {
				throw AssertionError( "Maintainer declaration ``decl`` has to satisfy 'TestMaintainer' interface" );
			}
		}
		else {
			return defaultRunner;
		}
	}
	
	
	"Returns maintainer declaration or `null` if not specified."
	ClassDeclaration? maintainerDeclaration( Package container ) {
		if ( exists maintainerDeclaration = container.annotations<MaintainerAnnotation>().first?.maintainerDeclaration ) {
			return maintainerDeclaration;
		}
		else if ( exists maintainerDeclaration = container.container.annotations<MaintainerAnnotation>().first?.maintainerDeclaration ) {
			return maintainerDeclaration;
		}
		else {
			return null;
		}
	}

	
	"Adds test to be run lately. If this is last test the execution is started."
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
		TestRunner testRunner = getRunner( functionDeclaration.containingPackage );
		testRunner.addTest( functionDeclaration, classDeclaration, parent, description );
		addedTestNumber ++;
		
		// if it is last test - execute all tests
		if ( addedTestNumber == totalTestNumber ) {
			for ( runner in runners.items ) {
				runner.run();
			}
			runners.clear();
			defaultRunner.run();
		}
	}
	
		
	"`true` if execution is performed using `AsyncTestExecutor`"
	Boolean isAsyncExecutedTest( FunctionDeclaration functionDeclaration ) {
		if ( nonempty ann = functionDeclaration.annotations<TestExecutorAnnotation>() ) {
			return ann.first.executor == asyncTestDeclaration;
		}
		if ( is ClassDeclaration cont = functionDeclaration.container ) {
			variable ClassDeclaration? exDecl = cont;
			while ( exists decl = exDecl ) {
				if ( nonempty ann = decl.annotations<TestExecutorAnnotation>() ) {
					return ann.first.executor == asyncTestDeclaration;
				}
				exDecl = decl.extendedType?.declaration;
			}
		}
		if ( nonempty ann = functionDeclaration.containingPackage.annotations<TestExecutorAnnotation>() ) {
			return ann.first.executor == asyncTestDeclaration;
		}
		else if ( nonempty ann = functionDeclaration.containingModule.annotations<TestExecutorAnnotation>() ) {
			return ann.first.executor == asyncTestDeclaration;
		}
		else {
			return false;
		}
	}
	
}
