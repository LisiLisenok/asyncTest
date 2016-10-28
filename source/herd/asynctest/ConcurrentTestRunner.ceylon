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


"Runs test on another thread and notifies when test is completed."
since( "0.3.0" )
by( "Lis" )
class ConcurrentTestRunner (
	"Processor to be run." AsyncTestProcessor processor,
	"Latch to control execution." CountDownLatch latch,
	"Lock of the [[ret]]." ReentrantLock retLock,
	"Array to store results." ArrayList<ExecutionTestOutput> ret
)
		satisfies Runnable
{
	shared actual void run() {
		try {
			value testResults = processor.runTest();
			retLock.lock();
			ret.add( testResults );
		}
		finally {
			retLock.unlock();
			latch.countDown();
		}
	}
}
