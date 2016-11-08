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
	ValueDeclaration
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
	ClassOrInterface
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
					// factory exists - use this to instantiate objecy
					if ( asyncTestRunner.isAsyncFactoryDeclaration( factory.factoryFunction ) ) {
						return FactoryContext( "``factory.factoryFunction.name``" ).run (
							( AsyncFactoryContext context ) {
								factory.factoryFunction.apply<>().apply( context );
							},
							extractTimeout( factory.factoryFunction )
						);
					}
					else {
						return FactoryContext( "``factory.factoryFunction.name``" ).run (
							( AsyncFactoryContext context ) {
								if ( exists ret = factory.factoryFunction.apply<>().apply() ) {
									context.fill( ret );
								}
								else {
									context.abort( FactoryReturnsNothing( "``factory.factoryFunction.name``" ) );
								}
							},
							extractTimeout( factory.factoryFunction )
						);
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
	ExecutionTestOutput[] runConcurrently (
		"Instance of the test class." Object? instance,
		"Type of the container." ClassOrInterface<Object>? instanceType
	) {
		Integer totalTests = executions.size;
		if ( totalTests > 1 ) {
			// array to store test results and lockerto synchronize results storing 
			ArrayList<ExecutionTestOutput> ret = ArrayList<ExecutionTestOutput>(); 
			ReentrantLock retLock = ReentrantLock();
			// executor and synchronizer
			ExecutorService executor = Executors.newFixedThreadPool( Runtime.runtime.availableProcessors() );
			CountDownLatch latch = CountDownLatch( totalTests );
			// run tests
			for ( test in executions ) {
				executor.execute (
					ConcurrentTestRunner (
						AsyncTestProcessor (
							test.functionDeclaration, instance, groupContext.childContext( test.description ),
							[], [], [] // doesn't apply test rules - not working in concurent mode
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
					first.functionDeclaration, instance, groupContext.childContext( first.description ),
					[], [], []
				).runTest()
			];
		}
		else { return []; }
	}
	
	"Runs all tests sequentially."
	ExecutionTestOutput[] runSequentially (
		"Instance of the test class." Object? instance,
		"Type of the container." ClassOrInterface<Object>? instanceType,
		"Functions called before each test." PrePostFunction[] intializers,
		"Statements called after each test - may modify test results." TestFunction[] statements,
		"Functions called after each test." PrePostFunction[] cleaners
	) {
		return [ for ( test in executions )
			AsyncTestProcessor (
				test.functionDeclaration, instance,
				groupContext.childContext( test.description ),
				intializers, statements, cleaners
			).runTest()
		];
	}

	
	"Extracts timeout from value and function name."
	Integer extractTimeoutFromObject( ValueDeclaration val, String functionName ) {
		if ( exists functionDecl = val.objectClass?.getDeclaredMemberDeclaration<FunctionDeclaration>( functionName ),
			nonempty list = functionDecl.annotations<TimeoutAnnotation>()
		) {
			return list.first.timeoutMilliseconds;
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
	PrePostFunction applyPrepostFunction( Object? instance, Function<Anything, Nothing> prepostFunction ) {
		// function declaration
		value decl = prepostFunction.declaration;
		// function arguments
		value args = resolveArgumentList( decl );
		// timeout
		value timeOut = extractTimeout( decl );
		
		if ( asyncTestRunner.isAsyncPrepostDeclaration( decl ) ) {
			return PrePostFunction (
				( AsyncPrePostContext context ) {
					prepostFunction.apply( context, *args );
				},
				timeOut, prepostFunction.declaration.name
			);
		}
		else {
			return PrePostFunction (
				( AsyncPrePostContext context ) {
					prepostFunction.apply( *args );
					context.proceed();
				},
				timeOut, prepostFunction.declaration.name
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
	

	"Returns a list of [[SuiteRule]] initializers."
	PrePostFunction[] getSuiteInitializers( Object? instance, ClassOrInterface<>? instanceType ) {
		if ( exists container = instance, exists containerType = instanceType ) {
			// attributes marked with `testRule`
			value suiteAttrs = containerType.getAttributes<Nothing, SuiteRule, Nothing>( asyncTestRunner.ruleAnnotationClass );
			return [ for ( attr in suiteAttrs ) PrePostFunction (
				attr.bind( container ).get().initialize,
				extractTimeoutFromObject( attr.declaration, "initialize" ), attr.declaration.name
			) ];
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			return [for ( attr in attrs ) if ( is SuiteRule rule = attr.get() ) PrePostFunction (
				rule.initialize, extractTimeoutFromObject( attr, "initialize" ), attr.name
			) ];
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
			value suiteRules = containerType.getAttributes<Nothing, SuiteRule, Nothing>( asyncTestRunner.ruleAnnotationClass );
			return [ for ( attr in suiteRules ) PrePostFunction (
				attr.bind( container ).get().dispose,
				extractTimeoutFromObject( attr.declaration, "dispose" ),
				attr.declaration.name
			) ];
		}
		else if ( is Package pack = container ) {
			value attrs = pack.annotatedMembers<ValueDeclaration, TestRuleAnnotation>();
			return [ for ( attr in attrs ) if ( is SuiteRule rule = attr.get() ) PrePostFunction (
				rule.dispose, extractTimeoutFromObject( attr, "dispose" ), attr.name
			) ];
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
	
	
	"Runs test initializers. Returns `true` if successfull and `false` if errored.
	 if errored fils test report with skipping."
	Boolean runInitializers( Object? instance, ClassOrInterface<>? instanceType ) {
		// overall test initializaers
		value testRunInits =
				if ( exists inst = instance )
				then getAnnotatedPrepost<BeforeTestRunAnnotation>( instance, instanceType )
					.append( getSuiteInitializers( instance, instanceType ) )
				else getSuiteInitializers( null, null );
		
		// context used for initialization / disposing
		PrePostContext prePostContext = PrePostContext( null );
		if ( nonempty initsRet = prePostContext.run ( testRunInits ) ) {
			// test has been skipped by some initializer
			// perform disposing and skip the test
			value cleaners =
					if ( exists inst = instance )
					then getAnnotatedPrepost<AfterTestRunAnnotation>( instance, instanceType )
						.append( getSuiteCleaners( instance, instanceType ) )
					else getSuiteCleaners( null, null );
			skipGroupTest( initsRet.append( prePostContext.run( cleaners ) ) );
			return false;
		}
		else {
			return true;
		}		
	}
	
	
	"Runs test cleaners. Returns sequence of cleaners output."
	TestOutput[] runCleaners( Object? instance, ClassOrInterface<>? instanceType ) {
		// overall test cleaners
		value cleaners =
				if ( exists inst = instance )
				then getAnnotatedPrepost<AfterTestRunAnnotation>( instance, instanceType )
					.append( getSuiteCleaners( instance, instanceType ) )
				else getSuiteCleaners( null, null );
		// context used for initialization / disposing
		PrePostContext prePostContext = PrePostContext( null );
		// perform all test disposing
		return prePostContext.run( cleaners );
	}
	
	"Combines test execution reports with overall cleaners report."
	ExecutionTestOutput[] combineTestReports (
		"Report of tests." ExecutionTestOutput[] testReport,
		"Report of overall cleaners." TestOutput[] disposeOut
	) {
		if ( disposeOut.empty ) {
			// no errors during dispose phase - just report on results
			return testReport;
		}
		else {
			// Disposing failure - report on this
			if ( is Package container ) {
				// add dispose failures to each test function
				return [ for ( o in testReport ) ExecutionTestOutput (
						o.context,
						o.variants.withTrailing( VariantTestOutput( [], [], disposeOut, 0, "", TestState.aborted ) ),
						o.elapsedTime, o.state
					) ];
			}
			else {
				// test class - report dispose failures as variants for class
				return testReport.withTrailing (
					ExecutionTestOutput (
						groupContext,
						[VariantTestOutput( [], [], disposeOut, 0, "", TestState.aborted )],
						0, TestState.aborted
					)
				);
			}
		}
	}
	
	
	"Adds new test to the group."
	shared void addTest (
		FunctionDeclaration functionDeclaration,
		TestDescription description
	) => executions.add( TestExecutionDescription( functionDeclaration, description ) );
	
	
	"Runs tests in this group."
	shared void run() {
		if ( nonempty conditions = evaluateContainerAnnotatedConditions( container, groupContext ) ) {
			// skip all tests since some conditions haven't met requirements
			skipGroupTest( conditions );
		}
		else {
			try {
				Integer startTime = system.milliseconds;
				Object? instance = instantiate();
				ClassOrInterface<Object>? instanceType = if ( exists i = instance ) then type( i ) else null;
				
				if ( runInitializers( instance, instanceType ) ) {
					// each test run initializers
					value testInitializers = getAnnotatedPrepost<BeforeTestAnnotation>( instance, instanceType )
							.append( getTestInitializers( instance, instanceType ) );
					// each test run cleaners
					value testCleaners = getAnnotatedPrepost<AfterTestAnnotation>( instance, instanceType )
							.append( getTestCleaners( instance, instanceType ) );
					// test statements
					value testStatements = getTestStatements( instance, instanceType );
					
					ExecutionTestOutput[] testReport;
					// perform testing
					if ( testInitializers.empty && testCleaners.empty && testStatements.empty && isConcurrent() ) {
						testReport = runConcurrently( instance, instanceType );
					}
					else {
						// if there are initializers, statements or cleaners the test can be performed only in sequential mode
						// since cleaner may clear some resources which are required for parallel execution
						// or must way completion which leads to the same sequential mode
						testReport = runSequentially (
							instance, instanceType, testInitializers, testStatements, testCleaners
						);
					}
					
					// perform all test disposing
					value disposeOut = runCleaners( instance, instanceType );
					// report on test results - use combined report of test execution and overall cleaners
					fillTestResults( combineTestReports( testReport, disposeOut), system.milliseconds - startTime );
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
			// for top-level functions add outputs to each function
			for ( execution in executions ) {
				TestExecutionContext context = groupContext.childContext( execution.description );
				fillContextWithTestResults( context,
					[VariantTestOutput(
						[], [], [], 0, "", TestState.skipped
					)], 0, TestState.skipped );
			}
		}
		else {
			// for class - skipeach function and add failures as class variants
			for ( execution in executions ) {
				TestExecutionContext context = groupContext.childContext( execution.description );
				context.fire().testStarted( TestStartedEvent( context.description ) );
				context.fire().testFinished( TestFinishedEvent (
					TestResult( context.description, TestState.skipped, false, null, 0 )
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
					TestResult( res.context.description, res.state, false )
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
		if ( variants.size == 1 && variants.first.variantName.empty ) {
			value outs = variants.first.initOutput.append( variants.first.testOutput ).append( variants.first.disposeOutput );
			if ( outs.empty ) {
				context.fire().testFinished( TestFinishedEvent (
					TestResult( context.description, overallState, false, null, runInterval )
				) );
			}
			else if ( outs.size == 1, exists firstOut = outs.first, firstOut.title.empty ) {
				context.fire().testFinished( TestFinishedEvent (
					TestResult( context.description, overallState, false, firstOut.error, runInterval )
				) );
			}
			else {
				Boolean combined = reportVariants( context, variants );
				context.fire().testFinished( TestFinishedEvent (
					TestResult( context.description, overallState, combined, null, runInterval )
				) );
			}
		}
		else {
			Boolean combined = reportVariants( context, variants );
			context.fire().testFinished( TestFinishedEvent (
				TestResult( context.description, overallState, combined, null, runInterval )
			) );
		}
	}
	
	"Reports a list of variants.  
	 Returns `true` if test results are combined and `false` otherwise."
	Boolean reportVariants (
		"Context to be filled with results." TestExecutionContext context,
		"List of variants." [VariantTestOutput+] variants
	) {
		variable Integer index = 0;
		variable Integer varIndex = variants.size > 1 then 1 else 0;
		variable Boolean combined = false;
		for ( var in variants ) {
			if ( !var.emptyOutput ) {
				String variantName =
					if ( varIndex > 0 ) then
					if ( var.variantName.empty ) then "arg#``varIndex``: " else
					if ( var.variantName.size > 40 ) then "arg#``varIndex``(...): "
					else "arg#``varIndex````var.variantName``: "
					else "";
				varIndex ++;
				for ( res in var.initOutput ) {
					variantResultEvent( context, variantName, res, ++ index );
				}
				for ( res in var.testOutput ) {
					variantResultEvent( context, variantName, res, ++ index );
				}
				for ( res in var.disposeOutput ) {
					variantResultEvent( context, variantName, res, ++ index );
				}
				combined = true;
			}
		}
		return combined;
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
