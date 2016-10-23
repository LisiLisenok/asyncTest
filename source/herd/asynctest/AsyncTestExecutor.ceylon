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
 * running test functions concurrently or sequentialy, see [[sequential]] annotation and [[module herd.asynctest]]
 * multi-reporting: several failures or successes can be reported for a one test execution,
   each report is represented as test variant and might be marked with `String` title
 * value- and type- parameterized testing with a set of function arguments, see [[parameterized]] for details
 * conditional execution with annotations satisfied `ceylon.test.engine.spi::TestCondition` interface
 
 In order to utilize this executor capabilities test function has to accept [[AsyncTestContext]] as the first argument:
 		test async)
 		void doTesting(AsyncTestContext context) {...}
 Test function can have more arguments if it is annotated with [[parameterized]] annotation. 
 
 #### Running
 
 To run the test using this executor apply [[async]] annotation at function, class, package or module level
 (alternatively, `ceylon.test::testExecutor` annotation with \`class AsyncTestExecutor\`
 argument may be applied).  
 Following procedure is as usual for SDK `ceylon.test` module - mark tested functions with `ceylon.test::test` annotation
 and run test in IDE or command line.  
 
 
 #### Test logic 
 
 When test function taking [[AsyncTestContext]] as first argument is executed it is expected the function will do following steps:
 1. Performing the test, reporting on failures via [[AsyncTestContext]].
    Several error or success reports are allowed. Each failure or success report is represented as test variant.
 2. Notifying test executor on test procedure completion - [[AsyncTestContext.complete]].
    This step is nesseccary to continue testing with next execution since test executor blocks execution thread until
    [[AsyncTestContext.complete]] is called.

 >Test function is responsible to catch all exceptions / assertions and to redirect them to `AsyncTestContext`.  


 >It is _not_ recommended to use `ceylon.test::assertXXX` functions together with [[AsyncTestContext]],
  since this functions throws an exception which may lead to immediate testing completion.
  Report via [[AsyncTestContext]] instead.  
 
 --------------------------------------------
 "
see( `function testExecutor`, `function async`, `interface AsyncTestContext` )
since( "0.0.1" )
by( "Lis" )
shared class AsyncTestExecutor (
	FunctionDeclaration functionDeclaration,
	ClassDeclaration? classDeclaration
)
		satisfies TestExecutor
{
	String getName() {
		if ( functionDeclaration.toplevel ) {
			return functionDeclaration.qualifiedName;
		} else {
			assert ( exists classDeclaration );
			return classDeclaration.qualifiedName + "." + functionDeclaration.name;
		}
	}

	shared actual TestDescription description = TestDescription( getName(), functionDeclaration, classDeclaration );
	
	shared actual void execute( TestExecutionContext parent ) {
		asyncTestRunner.addTest( functionDeclaration, classDeclaration, parent, description );
	}


	shared actual String string => "AsyncTestExecutor for ``getName()``";

}
