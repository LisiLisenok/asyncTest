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
	AtomicLong
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
tagged( "TestRule" ) since( "0.7.0" ) by( "Lis" )
shared class SignalRule() satisfies TestRule {
	
	class Box() {
		shared ReentrantLock lock = ReentrantLock();
		shared Condition condition = lock.newCondition();
		// counting of await, signal and signal all operations
		shared AtomicLong awaitCounts = AtomicLong( 0 );
		shared AtomicLong signalCounts = AtomicLong( 0 );
		shared AtomicLong signalAllCounts = AtomicLong( 0 );
		
		string => "signal rule";
	}
	
	CurrentTestStore<Box> stored = CurrentTestStore<Box>( Box );
	
	
	"Number of times the `await` has been called.  
	 Rested to zero _before each_ test."
	shared Integer numberOfAwaits => stored.element.awaitCounts.get();
	"Number of times the `signal` has been called.  
	 Rested to zero _before each_ test."
	shared Integer numberOfSignal => stored.element.signalCounts.get();
	"Number of times the `signalAll` has been called.  
	 Rested to zero _before each_ test."
	shared Integer numberOfSignalAll => stored.element.signalAllCounts.get();
	
	
	shared actual void after( AsyncPrePostContext context ) => stored.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => stored.before( context );
	
	
	"Causes the current thread to wait until it is signalled or interrupted, or the specified waiting time elapses.    
	 If `timeMilliseconds` is less or equal to zero then unlimited wait time is applied.  
	 Returns `false` if wait time is elapsed before `signal` or `signalAll` has been called
	 otherwise returns `true`.  
	 Note: always returns `true` if `timeMilliseconds` is less or equal to zero.  "
	shared Boolean await( "The maximum time to wait in milliseconds." Integer timeMilliseconds = -1 ) {
		Box box = stored.element;
		box.lock.lock();
		try {
			box.awaitCounts.incrementAndGet();
			if ( timeMilliseconds > 0 ) {
				return box.condition.await( timeMilliseconds, TimeUnit.milliseconds );
			}
			else {
				box.condition.await();
				return true;
			}
		}
		finally {
			box.lock.unlock();
		}
	}
	
	"Wakes up a one awaiter."
	shared void signal() {
		Box box = stored.element;
		box.lock.lock();
		try {
			box.signalCounts.incrementAndGet();
			box.condition.signal();
		}
		finally { box.lock.unlock(); }
	}
	
	"Wakes up all awaiters."
	shared void signalAll() {
		Box box = stored.element;
		box.lock.lock();
		try {
			box.signalAllCounts.incrementAndGet();
			box.condition.signalAll();
		}
		finally { box.lock.unlock(); }
	}
}

