import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration
}
import ceylon.test {
	TestDescription,
	testExecutor
}
import ceylon.test.engine.spi {
	TestExecutor,
	TestExecutionContext
}


"Async test executor.  
 
 #### Capabilities
 
 * testing asynchronous multithread code
 * running test functions concurrently or sequentialy, see [[alone]] annotation and [[module herd.asynctest]]
 * multi-reporting: several failures or successes can be reported, each report is represented as test variant
   and might be marked with `String` title
 * parameterized testing with a set of function arguments,
   see [[ceylon.test::parameters]] annotation and [[ceylon.test.engine.spi::ArgumentListProvider]] for details
 
 In order to utilize this executor capabilities test function has to accept [[AsyncTestContext]] as the first argument:
 		test testExecutor(\`class AsyncTestExecutor\`)
 		void doTesting(AsyncTestContext context) {...}
 Test function can have more arguments if it is annotated with [[ceylon.test::parameters]] annotation
 or another one which supports [[ceylon.test.engine.spi::ArgumentListProvider]]. 
 
 #### Running
 
 To run the test using this executor [[ceylon.test::testExecutor]] annotation with \`class AsyncTestExecutor\`
 argument to be applied at function, class, package or module level.  
 Following procedure is as usual for SDK `ceylon.test` module - mark tested functions with [[ceylon.test::test]] annotation
 and run test in IDE or command line.
 
 
 #### Test logic 
 
 When test function taking [[AsyncTestContext]] as first argument is executed it is expected the function will do following steps:
 1. Notifying test executor on test procedure starting - [[AsyncTestContext.start]].
 2. Performing the test, reporting on failures via [[AsyncTestContext]].
    Several error or success reports are allowed. Each failure or success report is represented as test variant.
 3. Notifying test executor on test procedure completion - [[AsyncTestContext.complete]].
    This step is nesseccary to continue testing with next execution since test executor blocks execution thread until
    [[AsyncTestContext.complete]] is called.

 >Test function is responsible to catch all exceptions / assertions and to redirect them to `AsyncTestContext`.
 
 >If test function doesn't take [[AsyncTestContext]] as first argument
  it is executed using [[ceylon.test.engine::DefaultTestExecutor]].

  
 #### Supported ceylon.test features
 * After / before test hooks can be used by applying [[ceylon.test::afterTest]] and [[ceylon.test::beforeTest]] annotations.
   Functions marked by these annotations are executed <i>synchronously</i> after and before test correspondently.
 * Parametrized test with a set of variants can be performed using [[ceylon.test::parameters]] annotation
   or another one which supports [[ceylon.test.engine.spi::ArgumentListProvider]].
 * Test can be skipped marking it by [[ceylon.test::ignore]] annotation.
 * Hooks the test with [[ceylon.test::TestListener]] can be used. But all events are raised after
   actual testing is completed. 
 * It is <i>not</i> recommended to use `ceylon.test::assertXXX` functions together with [[AsyncTestContext]],
   since this functions simply throws an exception which leads to testing completion. Use [[AsyncTestContext]] instead.
 
 "
by( "Lis" )
see( `function testExecutor` )
see( `interface AsyncTestContext` )
shared class AsyncTestExecutor (
	FunctionDeclaration functionDeclaration,
	ClassDeclaration? classDeclaration
)
		satisfies TestExecutor
{
	
	String descriptionName;
	if ( functionDeclaration.toplevel ) {
		descriptionName = functionDeclaration.qualifiedName;
	} else {
		assert ( exists classDeclaration );
		descriptionName = classDeclaration.qualifiedName + "." + functionDeclaration.name;
	}	

	shared actual TestDescription description = TestDescription( descriptionName, functionDeclaration, classDeclaration );
	
	shared actual void execute( TestExecutionContext parent ) {
		asyncTestRunner.addTest( functionDeclaration, classDeclaration, parent, description );
	}

}
