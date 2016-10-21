import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.test {

	TestDescription
}
import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration
}
import ceylon.collection {

	HashMap
}


"Owns and runs tests."
since( "0.2.0" )
by( "Lis" )
interface TestRunner {
	
	"Adds new test to the runner."
	shared formal void addTest (
		"Test function." FunctionDeclaration functionDeclaration,
		"Test function container if exists." ClassDeclaration? classDeclaration,
		"Parent test context." TestExecutionContext parent,
		"Test description." TestDescription description
	);
	
	"Runs all tests in the runner."
	shared formal void run();
	
}


"Base runner - stores tests without actual running."
by( "Lis" )
abstract class BaseTestRunner (
	"Emitter used to emit test events." shared TestEventEmitter eventEmitter
)
		satisfies TestRunner
{
	
	"Tests to be run."
	HashMap<TestGroup, TestGroupExecutor> groupMap = HashMap<TestGroup, TestGroupExecutor>();
	
	
	"Returns registered group for the given container or creates new one."
	TestGroupExecutor getGroupExecutor (
		"Group the executor is looked for." TestGroup group,
		"Context the group executed on."
		TestExecutionContext groupContext
	) {
		if ( exists groupExecutor = groupMap.get( group ) ) {
			return groupExecutor;
		}
		else {
			TestGroupExecutor groupExecutor = TestGroupExecutor (
				group.container,
				eventEmitter,
				groupContext
			);
			groupMap.put( group, groupExecutor );
			return groupExecutor;
		}
	}


	"Assembly of groups added to the runner as map of 'group' -> 'group executor'."
	see( ` function addTest ` )
	shared Map<TestGroup, TestGroupExecutor> testAssembly => groupMap; 
	
	
	shared actual default void addTest (
		FunctionDeclaration functionDeclaration,
		ClassDeclaration? classDeclaration,
		TestExecutionContext parent,
		TestDescription description
	) {
		TestGroupExecutor group = getGroupExecutor (
			TestGroup( classDeclaration else functionDeclaration.containingPackage ), parent
		);
		group.addTest( functionDeclaration, description );
	}
	
}
