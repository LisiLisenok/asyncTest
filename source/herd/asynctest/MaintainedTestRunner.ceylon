import ceylon.collection {

	HashMap,
	Hashtable,
	linked
}
import ceylon.test {

	TestState
}
import ceylon.language.meta {

	type
}


"Runs testing with maintainer."
since( "0.5.0" )
by( "Lis" )
class MaintainedTestRunner (
	"Test maintainer." TestMaintainer maintainer,
	"Emitter used to emit test events." TestEventEmitter eventEmitter
)
	extends BaseTestRunner( eventEmitter )
{
	
	"Runs tests in this runner."
	shared actual void run() {
		HashMap<TestGroup, TestGroupExecutor> testedGroups = HashMap<TestGroup, TestGroupExecutor> (
			linked, Hashtable(), testAssembly
		);
		HashMap<TestGroup, TestSummary> summary = HashMap<TestGroup, TestSummary>();
		// ask maintainer to sort test order
		TestGroup[] runOrder = maintainer.testRunStarted (
			testedGroups.keys.sort( increasing<TestGroup> )
		);
		// runs tests in specified order and collect results
		for ( group in runOrder ) {
			if ( exists executor = testedGroups.get( group ) ) {
				summary.put( group, executor.run() );
				testedGroups.remove( group );
			}
			else {
				throw AssertionError( "Test maintainer ``type( maintainer )`` asks to run not existsed test gtoup ``group``" );
			}
		}
		// skip unprocessed tests
		TestOutput[1] skip = [TestOutput( TestState.skipped, null, 0, "skipped by maintainer" )];
		for ( group->executor in testedGroups ) {
			summary.put( group, executor.skipGroupTest( skip ) );
		}
		// finishing test run
		maintainer.testRunFinished( summary );
	}
	
}
