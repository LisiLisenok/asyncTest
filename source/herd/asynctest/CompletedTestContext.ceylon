import ceylon.test {
	TestDescription
}
import ceylon.test.engine.spi {
	TestExecutionContext
}


"Test which has results and to be filled with when run."
by( "Lis" )
class CompletedTestContext(
	TestExecutionContext parent,
	TestDescription description,
	VariantTestOutput results
)
		satisfies RunnableTestContext
{
	
	shared actual void runTest() {
		TestExecutionContext context = parent.childContext( description );
		fillTestResults( context, results.outs, results.totalElapsedTime );
	}
	
}
