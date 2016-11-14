import java.lang {
	Runnable
}
import java.util.concurrent {
	CountDownLatch
}
import java.util.concurrent.locks {

	ReentrantLock
}
import ceylon.collection {

	ArrayList
}
import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}


"Runs test on another thread and notifies when test is completed."
since( "0.3.0" ) by( "Lis" )
class ConcurrentTestProcessor (
	"Test function." FunctionDeclaration functionDeclaration,
	"Object contained function or `null` if function is top level." Object? instance,
	"Test execution context of this function." TestExecutionContext functionContext,
	"Latch to control execution." CountDownLatch latch,
	"Lock of the [[ret]]." ReentrantLock retLock,
	"Array to store results." ArrayList<ExecutionTestOutput> ret
)
		extends AsyncTestProcessor(
			functionDeclaration, instance, functionContext, [], [], []
		)
		satisfies Runnable
{
	shared actual void run() {
		try {
			value testResults = runTest();
			retLock.lock();
			try { ret.add( testResults ); }
			finally { retLock.unlock(); }
		}
		finally { latch.countDown(); }
	}
}
