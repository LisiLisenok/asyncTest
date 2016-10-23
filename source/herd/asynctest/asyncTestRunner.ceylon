import ceylon.collection {
	HashMap
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
	Package,
	InterfaceDeclaration,
	OpenInterfaceType
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
since( "0.0.1" )
by( "Lis" )
object asyncTestRunner {

	
	"Async declaration memoization."
	InterfaceDeclaration asyncContextDeclaration = `interface AsyncTestContext`;
	
	"InitContext declaration memoization."
	InterfaceDeclaration initContextDeclaration = `interface AsyncInitContext`;
	
	"Cache async test executor declaration"
	ClassDeclaration asyncTestDeclaration = `class AsyncTestExecutor`;

		
	"Emitting results of the test."
	GeneralEventEmitter resultEmitter = GeneralEventEmitter();
		
	"Executors of test groups - package or class level."
	HashMap<String, TestGroupExecutor> executors = HashMap<String, TestGroupExecutor>(); 
	
	
	"total number of tests"
	variable Integer totalTestNumber = -1;
	
	"number of added tests"
	variable Integer addedTestNumber = 0;
	
	
	"Returns total number of test run using `AsyncTestContext` from the given descriptions."
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
	
	"Returns registered test executor for the given container or creates new one."
	TestGroupExecutor getTestExecutor (
		"Group the executor is looked for." ClassDeclaration | Package container,
		"Context the group executed on." TestExecutionContext groupContext
	) {
		if ( exists groupExecutor = executors.get( container.qualifiedName ) ) {
			return groupExecutor;
		}
		else {
			TestGroupExecutor groupExecutor = TestGroupExecutor (
				container,
				resultEmitter,
				groupContext
			);
			executors.put( container.qualifiedName, groupExecutor );
			return groupExecutor;
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
		getTestExecutor( classDeclaration else functionDeclaration.containingPackage, parent )
				.addTest( functionDeclaration, description );
		addedTestNumber ++;
		// if it is last test - execute all tests
		if ( addedTestNumber == totalTestNumber ) {
			for ( executor in executors.items ) {
				executor.run();
			}
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
	
	
	"Returns `true` if function runs async test == takes `AsyncTestContext` as first argument."
	shared Boolean isAsyncDeclaration( FunctionDeclaration functionDeclaration ) {
		if (
			is OpenInterfaceType argType = functionDeclaration.parameterDeclarations.first?.openType,
			argType.declaration == asyncContextDeclaration
		) {
			return true;
		}
		else {
			return false;
		}
	}
	
	"Returns `true` if function runs async test initialization == takes `AsyncInitContext` as first argument."
	shared Boolean isAsyncInitDeclaration( FunctionDeclaration functionDeclaration ) {
		if (
			is OpenInterfaceType argType = functionDeclaration.parameterDeclarations.first?.openType,
			argType.declaration == initContextDeclaration
		) {
			return true;
		}
		else {
			return false;
		}
	}
	
	
}
