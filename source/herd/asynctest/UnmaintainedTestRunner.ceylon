

"Test runner of unmaintained tests."
since( "0.5.0" )
by( "Lis" )
class UnmaintainedTestRunner( "Emitter used to emit test events." TestEventEmitter eventEmitter )
	extends BaseTestRunner( eventEmitter ) 
{

	shared actual void run() {
		<TestGroup->TestGroupExecutor>[] testGroups = testAssembly.sort( byKey<TestGroup>( increasing<TestGroup> ) );
		for ( group->executor in testGroups ) {
			executor.run();
		}
	}
	
}
