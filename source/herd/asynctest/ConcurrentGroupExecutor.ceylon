import java.lang {
	Runnable
}
import java.util.concurrent {
	CountDownLatch
}


"Runnable wrapper to the test group in order to execute in concurrently."
since( "0.5.0" ) by( "Lis" )
class ConcurrentGroupExecutor (
	"Group to be executed." TestGroupExecutor group,
	"Latch to await execution." CountDownLatch latch
)
		satisfies Runnable
{
	shared actual void run() {
		try { group.runTest(); }
		finally { latch.countDown(); }
	}
}
