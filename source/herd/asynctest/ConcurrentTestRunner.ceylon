import java.lang {
	Runnable
}
import java.util.concurrent {
	CountDownLatch
}


"Runs test on another thread and notifies when test is completed."
since( "0.3.0" )
by( "Lis" )
class ConcurrentTestRunner( AsyncTestProcessor context, CountDownLatch latch )
		satisfies Runnable
{
	shared actual void run() {
		context.runTest();
		latch.countDown();
	}
}
