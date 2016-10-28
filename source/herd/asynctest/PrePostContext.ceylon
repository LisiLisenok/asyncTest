import java.util.concurrent.atomic {
	AtomicBoolean
}
import java.util.concurrent.locks {
	ReentrantLock,
	Condition
}
import ceylon.test {

	TestState
}
import ceylon.collection {

	ArrayList
}


"Performs initialization or disposing."
since( "0.6.0" )
by( "Lis" )
class PrePostContext() satisfies AsyncPrePostContext
{
	
	"locks concurrent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();

	
	"`false` if initialization completed"
	AtomicBoolean running = AtomicBoolean( true );
	
	"non-null if aborted"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();
	
	
	shared actual void abort( Throwable reason, String title ) {
		if ( running.compareAndSet( true, false ) ) {
			outputs.add( TestOutput( TestState.aborted, reason, 0, title ) );
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	shared actual void proceed() {
		if ( running.compareAndSet( true, false ) ) {
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}

	
	"Runs initialization process. Returns errors if occured."
	shared TestOutput[] run( Anything(AsyncPrePostContext)[] inits ) {
		locker.lock();
		try {
			outputs.clear();
			for ( init in inits ) {
				running.set( true );
				init( this );
				// await initialization completion
				if ( running.get() ) { condition.await(); }
			}
			return outputs.sequence();
		}
		catch ( Throwable err ) {
			return [TestOutput( TestState.aborted, err, 0, "" )];
		}
		finally {
			outputs.clear();
			running.set( false );
			locker.unlock();
		}
	}
	
	
	shared actual String string {
		String compl = if ( running.get() ) then "running" else "completed";
		return "TestInitContext, status: '``compl``'";
	}
	
}




