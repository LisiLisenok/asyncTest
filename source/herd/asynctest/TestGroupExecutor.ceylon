import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.test {

	TestDescription,
	TestResult,
	TestState,
	TestListener
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
	Package,
	ValueDeclaration,
	NestableDeclaration
}
import ceylon.collection {

	LinkedList,
	ArrayList
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

	Function,
	ClassOrInterface,
	Attribute
}
import ceylon.language.meta {

	type,
	optionalAnnotation
}
import herd.asynctest.rule {

	SuiteRule,
	TestRule,
	TestRuleAnnotation,
	TestStatement
}
import java.util.concurrent.locks {

	ReentrantLock
}
import ceylon.test.event {

	TestFinishedEvent,
	TestStartedEvent
}


"Posseses and executes grouped tests."
since( "0.5.0" )
by( "Lis" )
class TestGroupExecutor (
	"Container the test is performed on." Package | ClassDeclaration container,
	"Context the group executed on." shared TestExecutionContext groupContext
) {	
	
	"Description of execution to be done."
	class TestExecutionDescription(
		"Test function." shared FunctionDeclaration functionDeclaration,
		"Description of the test." shared TestDescription description
	) {}
	
	"Executions the group contains."
	LinkedList<TestExecutionDescription> executions = LinkedList<TestExecutionDescription>();

	
	"Instantiates a test container if `ClassDeclaration`.
	 Returns `null` if top-level function is tested.
	 Throws if some errors occurred."
	Object? instantiate() {
		if ( is ClassDeclaration declaration = container ) {
			if ( declaration.anonymous ) {
				"Something wrong when get top-level object instance."
				assert ( exists objectInstance = declaration.objectValue?.get() );
				return objectInstance;
			}
			else {
				if ( exists factory = optionalAnnotation( `FactoryAnnotation`, declaration ) ) {
					if ( asyncTestRunner.isAsyncFactoryDeclaration( factory.factoryFunction ) ) {
						return FactoryContext( "factory ``factory.factoryFunction`` has been aborted" ).run (
							( AsyncFactoryContext context ) {
								factory.factoryFunction.apply<>().apply( context, *factory.argumentList() );
							}
						);
					}
					else {
						if ( exists ret = factory.factoryFunction.apply<>().apply( *factory.argumentList() ) ) {
							return ret;
						}
						else {
							throw AssertionError( "factory ``factory.factoryFunction`` returns `null`" );
						}
					}
				}
				else {
					// no factory specified - just instantiate
					return declaration.instantiate( [], *resolveArgumentList( declaration ) );
				}
			}
		}
		else {
			// top-level function
			return null;
		}
	}
	
	"`True` if package or module marked with [[concurrent]] annotation."
	Boolean isPackageOrModuleConcurrent( Package pac )
			=> pac.annotated<ConcurrentAnnotation>() || pac.container.annotated<ConcurrentAnnotation>();
	
	"`True` if the test to be performed in concurrent order and `false` otherwise."
	Boolean isConcurrent() {
		switch ( container )
		case ( is Package ) {
			return isPackageOrModuleConcurrent( container );
		}
		case ( is ClassDeclaration ) {
			variable ClassDeclaration? exDecl = container;
			while ( exists decl = exDecl ) {
				if ( decl.annotated<ConcurrentAnnotation>() ) {
					return true;
				}
				exDecl = decl.extendedType?.declaration;
			}
			return isPackageOrModuleConcurrent( container.containingPackage );
		}
	}
	
	"Runs all tests concurrently using fixed size thread pool with number of threads equal to number of available cores."
	ExecutionTestOutput[] runConcurrently( Object? instance ) {
		Integer totalTests = executions.size;
		if ( totalTests > 1 ) {
			ReentrantLock retLock = ReentrantLock();
			ArrayList<ExecutionTestOutput> ret = ArrayList<ExecutionTestOutput>(); 
			CountDownLatch latch = CountDownLatch( totalTests );
			ExecutorService executor = Executors.newFixedThreadPool( Runtime.runtime.availableProcessors() );
			for ( test in executions ) {
				executor.execute (
					ConcurrentTestRunner (
						AsyncTestProcessor (
							test.functionDeclaration, instance, groupContext, test.description,
							[], [], [], // doesn't apply test rules - not working in concurent mode
							extractTimeout( test.functionDeclaration )
						),
						latch, retLock, ret
					)
				);
			}
			latch.await();
			executor.shutdown();
			return ret.sequence();
		}
		else if ( exists first = executions.first ) {
			// just a one function - run it in sequential mode
			return [ AsyncTestProcessor (
					first.functionDeclaration, instance, groupContext, first.description,
					[], [], [], extractTimeout( first.functionDeclaration )
				).runTest()
			];
		}
		else { return []; }
	}
	
	"Runs all tests sequentially."
	ExecutionTestOutput[] runSequentially (
		Object? instance,
		PrePostFunction[] intializers,
		TestFunction[] statements,
		PrePostFunction[] cleaners
	) {
		return [ for ( test in executions )
			AsyncTestProcessor (
				test.functionDeclaration,
				instance,
				groupContext,
				test.description,
				intializers,
				statements,
				cleaners,
				extractTimeout( test.functionDeclaration )
			).runTest()
		];
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
	
	
	"Extracts timeout for the declaration."
	Integer extractTimeout( NestableDeclaration declaration ) {
		return if ( exists ann = findFirstAnnotation<TimeOutAnnotation>( declaration ) )
			then ann.timeOutMilliseconds else -1;
	}
	
	"Extracts timeout from value and function name."
	Integer extractTimeoutFromObject( ValueDeclaration val, String functionName ) {
		if ( exists functionDecl = val.objectClass?.getDeclaredMemberDeclaration<FunctionDeclaration>( functionName ),
			nonempty list = functionDecl.annotations<TimeOutAnnotation>()
		) {
				return list.first.timeOutMilliseconds;
		}
	 	return extractTimeout( val );
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
	
	"Applies prepost function, may take arguments according to `ArgumentsAnnotation`."
	PrePostFunction applyPrepostFunction( Object? instance, Function<Anything, Nothing> initFunction ) {
		value decl = initFunction.declaration;
		// function arguments
		value args = resolveArgumentList( decl );
		// timeout
		value timeOut = extractTimeout( decl );
		
		if ( asyncTestRunner.isAsyncPrepostDeclaration( decl ) ) {
			return PrePostFunction (
				( AsyncPrePostContext context ) {
					initFunction.apply( context, *args );
				},
				timeOut,
				initFunction.declaration.name
			);
		}
		else {
			return PrePostFunction (
				( AsyncPrePostContext context ) {
					initFunction.apply( *args );
					context.proceed();
				},
				timeOut,
				initFunction.declaration.name
			);
		}
	}
	
	"Returns a list of initializers."
	PrePostFunction[] getAnnotatedPrepost<AnnotationType>( Object? instance, ClassOrInterface<>? instanceType )
			given AnnotationType satisfies Annotation
	{
		Function<Anything, Nothing>[] decls = getAnnotatedFunctions<AnnotationType>( instance, instanceType );
		return [for ( decl in decls ) applyPrepostFunction( instance, decl ) ];
	}
	
	
	"Aborts initialization / disposing with incorrect `testRule` annotation usage."
	void reportTestRuleAnnotationError( ValueDeclaration[] incorrectDeclarations )( AsyncPrePostContext context )
		=> context.abort (
			AssertionError (
				"Attributes annotated with testRule have to satisfy TestRule or TestSuite interface:
			  	``incorrectDeclarations``"
			),
			"incorrect testRule annotation usage"
		);

	
	"Returns a list of [[SuiteRule]] initializers."
	PrePostFunction[] getSuiteInitializers( Object? instance, ClassOrInterface<>? instanceType ) {
		if ( exists container = instance, exists containerType = instanceType ) {
			value markedWithRule = containerType.getAttributes<Nothing, Anything, Nothing>( asyncTestRunner.ruleAnnotationClass );
			value incorrectAttrs = [ for ( attr in markedWithRule )
				if ( !is Attribute<Nothing, SuiteRule|TestRule|TestStatement, Nothing> attr) attr ];
			value suiteAttrs = markedWithRule.narrow<Attribute<Nothing, SuiteRule, Nothing>>();
			if ( incorrectAttrs.empty ) {
				return [ for ( attr in suiteAttrs ) PrePostFunction (
					attr.bind( container ).get().initialize,
					extractTimeoutFromObject( attr.declaration, "initialize" ), attr.declaration.name
				) ];
			}
			else {
				return [ PrePostFunction (
					reportTestRuleAnnotationError (
						incorrectAttrs.map( (Attribute<Nothing, Anything, Nothing> attr) => attr.declaration ).sequence() ),
					-1, "" )
				];
			}
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			value incorrectValues = attrs.filter (
				( ValueDeclaration decl ) => !decl.get() is SuiteRule|TestRule|TestStatement
			);
			if ( incorrectValues.empty ) {
				return [for ( attr in attrs ) if ( is SuiteRule rule = attr.get() ) PrePostFunction (
					rule.initialize, extractTimeoutFromObject( attr, "initialize" ), attr.name
				) ];
			}
			else {
				return [ PrePostFunction (
					reportTestRuleAnnotationError( incorrectValues.sequence() ),
					-1, ""
				) ];
			}
		}
		else {
			return [];
		}
	}
	
	"Returns a list of [[TestRule]] initializers."
	PrePostFunction[] getTestInitializers( Object? instance, ClassOrInterface<>? instanceType )
	{
		if ( exists container = instance, exists containerType = instanceType ) {
			value attrs = containerType.getAttributes<Nothing, TestRule, Nothing>( asyncTestRunner.ruleAnnotationClass );
			return [ for ( attr in attrs ) PrePostFunction (
				attr.bind( container ).get().before,
				extractTimeoutFromObject( attr.declaration, "before" ),
				attr.declaration.name
			) ];
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			return [for ( attr in attrs ) if ( is TestRule rule = attr.get() ) PrePostFunction (
				rule.before, extractTimeoutFromObject( attr, "before" ), attr.name
			) ]; 
		}
		else {
			return [];
		}
	}
	
	
	"Returns a list of [[TestStatement]] applicators."
	TestFunction[] getTestStatements( Object? instance, ClassOrInterface<>? instanceType )
	{
		if ( exists container = instance, exists containerType = instanceType ) {
			value attrs = containerType.getAttributes<Nothing, TestStatement, Nothing>( asyncTestRunner.ruleAnnotationClass );
			return [ for ( attr in attrs ) TestFunction (
				attr.bind( container ).get().apply,
				extractTimeoutFromObject( attr.declaration, "apply" ),
				attr.declaration.name
			) ];
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			return [for ( attr in attrs ) if ( is TestStatement statement = attr.get() ) TestFunction (
				statement.apply, extractTimeoutFromObject( attr, "apply" ), attr.name
			) ];
		}
		else {
			return [];
		}
	}

	
	"Returns a list of [[SuiteRule]] cleaners."
	PrePostFunction[] getSuiteCleaners( Object? instance, ClassOrInterface<>? instanceType )
	{
		if ( exists container = instance, exists containerType = instanceType ) {
			value markedWithRule = containerType.getAttributes<Nothing, Anything, Nothing>( asyncTestRunner.ruleAnnotationClass );
			if ( markedWithRule.find (
					( Attribute<Nothing, Anything, Nothing> attr )
						=> !attr is Attribute<Nothing, SuiteRule|TestRule|TestStatement, Nothing>
				) exists
			) {
				// if incorrect attrs exists - returns empty since no initialization has to be performed
				return [];
			}
			else {
				value attrs = markedWithRule.narrow<Attribute<Nothing, SuiteRule, Nothing>>();
				return [ for ( attr in attrs ) PrePostFunction (
					attr.bind( container ).get().dispose,
					extractTimeoutFromObject( attr.declaration, "dispose" ),
					attr.declaration.name
				) ];
			}
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			if ( attrs.find( ( ValueDeclaration attr ) => !attr.get() is SuiteRule|TestRule|TestStatement ) exists ) {
				// if incorrect attrs exists - returns empty since no initialization has to be performed
				return [];
			}
			else {
				return [ for ( attr in attrs ) if ( is SuiteRule rule = attr.get() ) PrePostFunction (
					rule.dispose, extractTimeoutFromObject( attr, "dispose" ), attr.name
				) ];
			}
		}
		else {
			return [];
		}
	}
	
	"Returns a list of [[TestRule]] cleaners."
	PrePostFunction[] getTestCleaners( Object? instance, ClassOrInterface<>? instanceType )
	{
		if ( exists container = instance, exists containerType = instanceType ) {
			value attrs = containerType.getAttributes<Nothing, TestRule, Nothing>( asyncTestRunner.ruleAnnotationClass );
			return [ for ( attr in attrs ) PrePostFunction (
				attr.bind( container ).get().after,
				extractTimeoutFromObject( attr.declaration, "after" ),
				attr.declaration.name 
			) ]; 
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			return [for ( attr in attrs ) if ( is TestRule rule = attr.get() ) PrePostFunction (
				rule.after, extractTimeoutFromObject( attr, "after" ), attr.name
			) ];
		}
		else {
			return [];
		}
	}
	
	
	"Adds new test to the group."
	shared void addTest (
		FunctionDeclaration functionDeclaration,
		TestDescription description
	) => executions.add( TestExecutionDescription( functionDeclaration, description ) );
	
	
	"Runs tests in this group."
	shared void run() {
		if ( evaluateConditions() ) {
			try {
				Integer startTime = system.milliseconds;
				Object? instance = instantiate();
				ClassOrInterface<>? instanceType = if ( exists i = instance ) then type( i ) else null;
				// overall test initializaers
				value testRunInits =
						if ( exists inst = instance )
						then getAnnotatedPrepost<BeforeTestRunAnnotation>( instance, instanceType )
							.append( getSuiteInitializers( instance, instanceType ) )
						else getSuiteInitializers( null, null );
				// overall test cleaners
				value cleaners =
						if ( exists inst = instance )
						then getAnnotatedPrepost<AfterTestRunAnnotation>( instance, instanceType )
							.append( getSuiteCleaners( instance, instanceType ) )
						else getSuiteCleaners( null, null );
				
				// context used for initialization / disposing
				PrePostContext prePostContext = PrePostContext();
				
				if ( nonempty initsRet = prePostContext.run ( testRunInits ) ) {
					// test has been skipped by some initializer
					// perform disposing and skip the test
					value clrRet = prePostContext.run( cleaners );
					skipGroupTest( initsRet.append( clrRet ) );
				}
				else {
					// each test run initializers
					value testInitializers = getAnnotatedPrepost<BeforeTestAnnotation>( instance, instanceType )
							.append( getTestInitializers( instance, instanceType ) );
					// each test run cleaners
					value testCleaners = getAnnotatedPrepost<AfterTestAnnotation>( instance, instanceType )
							.append( getTestCleaners( instance, instanceType ) );
					// test statements
					value testStatements = getTestStatements( instance, instanceType );
					
					ExecutionTestOutput[] outs;
					// perform testing
					if ( testInitializers.empty && testCleaners.empty && testStatements.empty && isConcurrent() ) {
						outs = runConcurrently( instance );
					}
					else {
						// if there are initializers, statements or cleaners the test can be performed only in sequential mode
						// since cleaner may clear some resources which are required for parallel execution
						// or must way completion which leads to the same sequential mode
						outs = runSequentially (
							instance, testInitializers, testStatements, testCleaners
						);
					}
					
					// perform all test disposing
					value disposeOut = prePostContext.run( cleaners );
					
					if ( disposeOut.empty ) {
						fillTestResults( outs, system.milliseconds - startTime );
					}
					else {
						if ( is Package container ) {
							fillTestResults (
								[ for ( o in outs ) ExecutionTestOutput (
									o.context,
									o.variants.withTrailing ( VariantTestOutput (
										[], [], disposeOut, 0, "", TestState.aborted
									) ),
									o.elapsedTime,
									o.state
								) ],
								system.milliseconds - startTime
							);
						}
						else {
							fillTestResults ( outs.withTrailing (
								ExecutionTestOutput (
									groupContext,
									[VariantTestOutput( [], [], disposeOut, 0, "", TestState.aborted )],
									0,
									TestState.aborted
								) ),
								system.milliseconds - startTime
							);
						}
					}
				}
			}
			catch ( Throwable err ) {
				skipGroupTest( [TestOutput( TestState.aborted, err, 0, "" )] );
			}
		}
	}
	
	
	"Skips all tests in the group."
	shared void skipGroupTest( [TestOutput+] outputs ) {
		groupContext.fire().testStarted( TestStartedEvent( groupContext.description ) );
		if ( is Package container ) {
			for ( execution in executions ) {
				TestExecutionContext context = groupContext.childContext( execution.description );
				fillContextWithTestResults( context,
					[VariantTestOutput(
						[], [], [], 0, "", TestState.skipped
					)], 0, TestState.skipped );
			}
		}
		else {
			for ( execution in executions ) {
				TestExecutionContext context = groupContext.childContext( execution.description );
				context.fire().testStarted( TestStartedEvent( context.description ) );
				context.fire().testFinished( TestFinishedEvent (
					TestResult( context.description, TestState.skipped, true, null, 0 )
				) );
			}
			variable Integer index = 0;
			for ( res in outputs ) {
				variantResultEvent( groupContext, "", res, ++ index );
			}
		}
		groupContext.fire().testFinished( TestFinishedEvent (
			TestResult( groupContext.description, TestState.skipped, true, null, 0 )
		) );
	}

	
	"Fills the context with test results."
	void fillTestResults( ExecutionTestOutput[] results, Integer overallTime ) {
		groupContext.fire().testStarted( TestStartedEvent( groupContext.description ) );
		variable TestState overallState = TestState.skipped;
		for ( res in results ) {
			if ( nonempty vars = res.variants ) {
				fillContextWithTestResults( res.context, vars, res.elapsedTime, res.state );
			}
			else {
				res.context.fire().testStarted( TestStartedEvent( res.context.description ) );
				res.context.fire().testFinished( TestFinishedEvent (
					TestResult( res.context.description, TestState.success, false )
				) );
			}
			
			if ( res.state > overallState ) { overallState = res.state; }
		}
		groupContext.fire().testFinished( TestFinishedEvent (
			TestResult( groupContext.description, overallState, true, null, overallTime )
		) );
	}
	
	"Fills results of the test to execution context. Here in order to avoind race conditions when filling to test runner."
	shared default void fillContextWithTestResults (
		"Context to be filled with results." TestExecutionContext context,
		"List of variants." [VariantTestOutput+] variants,
		"Total test elapsed time." Integer runInterval,
		"Overall test state." TestState overallState
	) {
		context.fire().testStarted( TestStartedEvent( context.description ) );
		variable Integer index = 0;
		for ( var in variants ) {
			String variantName = if ( var.variantName.empty ) then "" else var.variantName + ": ";
			for ( res in var.initOutput ) {
				variantResultEvent( context, variantName, res, ++ index );
			}
			for ( res in var.testOutput ) {
				variantResultEvent( context, variantName, res, ++ index );
			}
			for ( res in var.disposeOutput ) {
				variantResultEvent( context, variantName, res, ++ index );
			}
		}
		context.fire().testFinished( TestFinishedEvent (
			TestResult( context.description, overallState, true, null, runInterval )
		) );
	}
	
	"Raises test variant results event."
	void variantResultEvent (
		"Context to raise event on." TestExecutionContext context,
		"Name of the variant." String variantName,
		"Test output to be passed as variant result." TestOutput testOutput,
		"Variant index." Integer index
	) {
		TestDescription variant = context.description.forVariant( variantName + testOutput.title, index );
		TestExecutionContext child = context.childContext( variant );
		TestListener listener = child.fire();
		listener.testStarted( TestStartedEvent( variant ) );
		listener.testFinished( TestFinishedEvent(
			TestResult( variant, testOutput.state, false, testOutput.error, testOutput.elapsedTime )
		) );
	}
	
}
