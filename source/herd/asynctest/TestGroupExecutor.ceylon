import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.test {

	TestDescription,
	TestResult,
	TestState
}
import ceylon.test.annotation {
	BeforeTestRunAnnotation,
	AfterTestRunAnnotation,
	BeforeTestAnnotation,
	AfterTestAnnotation
}
import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration,
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
import ceylon.language.meta.model {

	IncompatibleTypeException,
	InvocationException,
	Function,
	ClassOrInterface
}
import ceylon.language.meta {

	type
}


"Posseses and executes grouped tests."
since( "0.5.0" )
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
		if ( is ClassDeclaration declaration = container ) {
			if ( declaration.anonymous ) {
				assert ( exists objectInstance = declaration.objectValue?.get() );
				return objectInstance;
			}
			else {
				return declaration.instantiate( [], *resolveArgumentList( declaration ) );
			}
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
	
	"Runs all tests concurrently using fixed size thread pool with number of threads equal to number of available cores."
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
							test.description,
							[], [] // doesn't send initializers and cleaners - not working in concurent mode
						),
						latch
					)
				);
			}
			latch.await();
			executor.shutdown();
		}
		else if ( exists first = executions.first ) {
			// just a one function - run it in sequential mode
			AsyncTestProcessor (
				resultCollector,
				first.functionDeclaration,
				instance,
				groupContext,
				first.description,
				[], []
			).runTest();
		}
	}
	
	"Runs all tests sequentially."
	void runSequentially( Object? instance, Anything(AsyncInitContext)[] intializers, Anything(AsyncTestContext)[] cleaners ) {
		for ( test in executions ) {
			AsyncTestProcessor (
				resultCollector,
				test.functionDeclaration,
				instance,
				groupContext,
				test.description,
				intializers,
				cleaners
			).runTest();
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
	void finalizeTest() {
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
	}
	
	
	"Returns a list of annotated functions of the container."
	Function<Anything, Nothing>[] getAnnotatedFunctions<AnnotationType>( Object? instance, ClassOrInterface<>? instanceType )
			given AnnotationType satisfies Annotation
	{
		if ( exists instance, exists instanceType ) {
			return [ for ( item in instanceType.getMethods<Nothing, Anything, Nothing>( `AnnotationType` ) )
						item.bind( instance ) ];
		}
		else if ( is Package cont = container ) {
			return [ for ( item in cont.annotatedMembers<FunctionDeclaration, AnnotationType>() )
						item.apply<Anything, Nothing>() ];
		}
		else {
			return [];
		}
	}
	
	"Applies initializer function, may take arguments according to `ArgumentsAnnotation`."
	Anything(AsyncInitContext) applyInitializerFunction( Object? instance, Function<Anything, Nothing> initFunction )
	{
		value decl = initFunction.declaration;
		// function arguments
		value args = resolveArgumentList( decl );
		
		if ( asyncTestRunner.isAsyncInitDeclaration( decl ) ) {
			return ( AsyncInitContext context ) {
				try {
					initFunction.apply( context, *args );
				}
				catch ( IncompatibleTypeException | InvocationException err ) {
					context.abort( err, "incompatible invocation of ``decl.qualifiedName``" );
				}
			};
		}
		else {
			return ( AsyncInitContext context ) {
				try {
					initFunction.apply( *args );
					context.proceed();
				}
				catch ( IncompatibleTypeException | InvocationException err ) {
					context.abort( err, "incompatible invocation of ``decl.qualifiedName``" );
				}
			};
		}
	}
	
	"Returns a list of initializers."
	Anything(AsyncInitContext)[] getContainerInitializers<AnnotationType>( Object? instance, ClassOrInterface<>? instanceType )
			given AnnotationType satisfies Annotation
	{
		Function<Anything, Nothing>[] decls = getAnnotatedFunctions<AnnotationType>( instance, instanceType );
		return [for ( decl in decls ) applyInitializerFunction( instance, decl ) ];
	}
	
	
	"Applies cleaner function, may take arguments according to `ArgumentsAnnotation`."
	Anything(AsyncTestContext) applyCleanerFunction( Object? instance, Function<Anything, Nothing> cleanerFunction )
	{
		// function arguments
		value decl = cleanerFunction.declaration;
		value args = resolveArgumentList( decl );
		if ( asyncTestRunner.isAsyncDeclaration( decl ) ) {
			return ( AsyncTestContext context ) {
				try {
					cleanerFunction.apply( context, *args );
				}
				catch ( IncompatibleTypeException | InvocationException err ) {
					context.abort( err, "dispose with incompatible invocation of ``decl.qualifiedName``" );
					context.complete();
				}
			};
		}
		else {
			return ( AsyncTestContext context ) {
				try {
					cleanerFunction.apply( *args );
				}
				catch ( IncompatibleTypeException | InvocationException err ) {
					context.abort( err, "dispose with incompatible invocation of ``decl.qualifiedName``" );
				}
				context.complete();
			};
		}
	}
	
	"Returns a list of cleaners."
	Anything(AsyncTestContext)[] getContainerCleaners<AnnotationType>( Object? instance, ClassOrInterface<>? instanceType )
			given AnnotationType satisfies Annotation
	{
		Function<Anything, Nothing>[] decls = getAnnotatedFunctions<AnnotationType>( instance, instanceType );
		return [for ( decl in decls ) applyCleanerFunction( instance, decl ) ];
	}
	
	
	"Adds new test to the group."
	shared void addTest (
		FunctionDeclaration functionDeclaration,
		TestDescription description
	) => executions.add( TestExecutionDescription( functionDeclaration, description ) );
	
	
	"Skips all tests in the group."
	shared void skipGroupTest( [TestOutput+] outputs ) {
		resultCollector.startRecording();
		resultCollector.startEvent( groupContext );
		for ( execution in executions ) {
			TestExecutionContext context = groupContext.childContext( execution.description );
			resultCollector.fillTestResults( context, outputs, 0, 0 );
		}
		finalizeTest();
	}
	
	"Runs tests in this group."
	shared void run() {
		resultCollector.startRecording();
		resultCollector.startEvent( groupContext );
		
		if ( evaluateConditions() ) {
			try {
				Object? instance = instantiate();
				ClassOrInterface<>? intanceType = if ( exists i = instance ) then type( i ) else null;
				// beforeTestRun is checked only for member functions!
				if ( instance exists, exists ret = InitializerContext().run (
						getContainerInitializers<BeforeTestRunAnnotation>( instance, intanceType ) )
				) {
					skipGroupTest( [ret] );
				}
				else {
					// get initializers and cleaners
					value testInitializers = getContainerInitializers<BeforeTestAnnotation>( instance, intanceType );
					value testCleaners = getContainerCleaners<AfterTestAnnotation>( instance, intanceType );
					
					// perform testing
					if ( !testInitializers.empty || !testCleaners.empty || isSequential() ) {
						// if there are initializers or cleaners test can be performed only in sequential mode
						// since cleaner may clear some resources which are required for parallel execution
						// or must way completion which leads to the same sequential mode
						runSequentially( instance, testInitializers, testCleaners );
					}
					else {
						runConcurrently( instance );
					}
					
					// perform disposing only for member functions
					if ( instance exists ) {
						value cleaners = getContainerCleaners<AfterTestRunAnnotation>( instance, intanceType );
						Tester tester = Tester();
						for ( cleaner in cleaners ) {
							value output = tester.run( cleaner );
							if ( !output.empty ) {
								resultCollector.fillTestResults( groupContext, output, tester.runInterval, 1 );
							}
						}
					}
					
					// report test results
					finalizeTest();
				}
			}
			catch ( Throwable err ) {
				skipGroupTest( [TestOutput( TestState.aborted, err, 0, "" )] );
			}
		}		
	}
	
}
