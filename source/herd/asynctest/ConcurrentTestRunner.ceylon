import java.lang {
	Runnable
}
import java.util.concurrent {
	CountDownLatch
}


"Runs test on another thread and notifies when test is completed."
by( "Lis" )
class ConcurrentTestRunner( RunnableTestContext context, CountDownLatch latch )
		satisfies Runnable
{
	shared actual void run() {
		context.runTest();
		latch.countDown();
	}
}
