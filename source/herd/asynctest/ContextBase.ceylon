import java.util.concurrent.locks {
	Condition,
	ReentrantLock
}
import java.util.concurrent.atomic {
	AtomicBoolean
}


"Base class for several contexts. Provide await and signalling capability."
see( `interface AsyncTestContext`, `interface AsyncPrePostContext`, `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
class ContextBase() {
	"`true` if context still running"
	shared AtomicBoolean running = AtomicBoolean( true );
	
	"locks concurrent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();
	
	"Signals the condition."
	shared void signal() {
		locker.lock();
		try { condition.signal(); }
		finally { locker.unlock(); }
	}
	
	"Await signaling."
	shared void await() {
		if ( running.get() ) {
			locker.lock();
			try { condition.await(); }
			finally { locker.unlock(); }
		}
	}	
}
