import herd.asynctest {
	AsyncPrePostContext
}
import java.util.concurrent.locks {
	ReentrantLock,
	Condition
}
import java.util.concurrent {
	TimeUnit
}
import java.util.concurrent.atomic {
	AtomicInteger
}


"Provides suspend / resume capability. The rule might be applied when some thread
 has to await another one completes some calculations.  
 
 Example:
 
 
 		class MyTest() {
 			SignalRule rule = SignalRule();
 
 			test async void myTest(AsyncTestContext context) {
 				object thread1 extends Thread() {
 					shared actual void run() {
 						rule.await(); // awaits until thread2 signals
 						... verify thread 2 work results ...
 						context.complete();
 					}
 				}
 				thread1.start();
 				
 				object thread2 extends Thread() {
 					shared actual void run() {
 						... do some work ...
 						rule.signal(); // wakes up thread1
 					}
 				}
 				thread2.start();
 			}
 		}
 "
tagged( "TestRule" ) since( "0.6.1" ) by( "Lis" )
shared class SignalRule() satisfies TestRule {
	
	variable ReentrantLock lock = ReentrantLock();
	variable Condition condition = lock.newCondition();
	
	// counting of await, signal and signal all operations
	variable AtomicInteger awaitCounts = AtomicInteger( 0 );
	variable AtomicInteger signalCounts = AtomicInteger( 0 );
	variable AtomicInteger signalAllCounts = AtomicInteger( 0 );
	
	
	"Number of times the `await` has been called.  
	 Rested to zero _before each_ test."
	shared Integer numberOfAwaits => awaitCounts.get();
	"Number of times the `signal` has been called.  
	 Rested to zero _before each_ test."
	shared Integer numberOfSignal => signalCounts.get();
	"Number of times the `signalAll` has been called.  
	 Rested to zero _before each_ test."
	shared Integer numberOfSignalAll => signalAllCounts.get();
	
	
	shared actual void after( AsyncPrePostContext context ) {
		context.proceed();
	}
	
	shared actual void before( AsyncPrePostContext context ) {
		awaitCounts = AtomicInteger( 0 );
		signalCounts = AtomicInteger( 0 );
		signalAllCounts = AtomicInteger( 0 );
		lock = ReentrantLock();
		condition = lock.newCondition();
		context.proceed();
	}
	
	
	"Causes the current thread to wait until it is signalled or interrupted, or the specified waiting time elapses.    
	 If `timeMilliseconds` is less or equal to zero then unlimited wait time is applied.  
	 Returns `false` if wait time is elapsed before `signal` or `signalAll` has been called
	 otherwise returns `true`.  
	 Note: always returns `true` if `timeMilliseconds` is less or equal to zero.  "
	shared Boolean await( "The maximum time to wait in milliseconds." Integer timeMilliseconds = -1 ) {
		lock.lock();
		try {
			awaitCounts.incrementAndGet();
			if ( timeMilliseconds > 0 ) {
				return condition.await( timeMilliseconds, TimeUnit.milliseconds );
			}
			else {
				condition.await();
				return true;
			}
		}
		finally {
			lock.unlock();
		}
	}
	
	"Wakes up a one awaiter."
	shared void signal() {
		lock.lock();
		try {
			signalCounts.incrementAndGet();
			condition.signal();
		}
		finally { lock.unlock(); }
	}
	
	"Wakes up all awaiters."
	shared void signalAll() {
		lock.lock();
		try {
			signalAllCounts.incrementAndGet();
			condition.signalAll();
		}
		finally { lock.unlock(); }
	}
}

