import ceylon.collection {

	HashMap
}
import ceylon.language.meta.declaration {

	FunctionDeclaration,
	NestableDeclaration,
	OpenInterfaceType
}
import ceylon.test {

	TestDescription
}
import ceylon.test.engine.spi {

	TestExecutionContext
}


"Runs initialization"
by( "Lis" )
object initializer {
	
	"initialized values"
	HashMap<FunctionDeclaration, InitStorage | InitError> inits = HashMap<FunctionDeclaration, InitStorage | InitError>(); 
	
	
	"total number of tests"
	variable Integer testNumber = -1;
	
	
	"performs initialization"
	InitStorage | InitError runInitialization( FunctionDeclaration declaration ) {
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
	
	"disposes all storages"
	void dispose() {
		value list = inits.items.narrow<InitStorage>();
		for ( con in list ) { con.dispose(); }
		inits.clear();
	}
	
	InitStorage | InitError initTest (
		FunctionDeclaration functionDeclaration
	) {
		if ( nonempty ann = functionDeclaration.annotations<InitAnnotation>() ) {
			return runInitialization( ann.first.initializer );
		}
		else if ( is NestableDeclaration cont = functionDeclaration.container ) {
			if ( nonempty ann = cont.annotations<InitAnnotation>() ) {
				return runInitialization( ann.first.initializer );
			}
			else {
				return EmptyInitStorage();
			}
		}
		else if ( nonempty ann = functionDeclaration.containingPackage.annotations<InitAnnotation>() ) {
			return runInitialization( ann.first.initializer );
		}
		else if ( nonempty ann = functionDeclaration.containingModule.annotations<InitAnnotation>() ) {
			return runInitialization( ann.first.initializer );
		}
		else {
			return EmptyInitStorage();
		}
	}
	
	
	Integer numberOfAsyncTest( TestDescription* descriptions ) {
		variable Integer ret = 0;
		for ( descr in descriptions ) {
			if ( exists fDeclaration = descr.functionDeclaration, isAsyncDeclaration( fDeclaration ) ) {
				ret ++;
			}
			ret += numberOfAsyncTest( *descr.children );
		}
		return ret;
	}
	
	"returns initializations"
	shared InitStorage | InitError testStarted (
		TestExecutionContext context,
		FunctionDeclaration functionDeclaration
	) {
		// calculates number of async tests
		if ( testNumber < 0 ) {
			variable TestExecutionContext root = context;
			while ( exists h = root.parent ) { root = h; }
			testNumber = numberOfAsyncTest( root.description );
		}
		
		// initialize test
		return initTest( functionDeclaration );
	}
	
	"test completeed notification, when all tests are completed disposing init values"
	shared void testCompleted() {
		testNumber --;
		if ( testNumber == 0 ) { dispose(); }
	}
	
	"returns `true` if function runs async test"
	shared Boolean isAsyncDeclaration( FunctionDeclaration functionDeclaration ) {
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
	
}
