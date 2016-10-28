import java.util.concurrent.locks {
	Condition,
	ReentrantLock
}
import java.util.concurrent.atomic {
	AtomicBoolean
}


"Implementation of [[AsyncFactoryContext]]"
see( `function factory` )
since( "0.6.0" ) by( "Lis" )
class FactoryContext( "title used ifno reasonspecified at abort" String title ) satisfies AsyncFactoryContext
{
	
	"locks concurrent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();
	
	"`false` if object has been instantiated."
	AtomicBoolean running = AtomicBoolean( true );
	
	"non-null if aborted"
	variable Throwable? abortReason = null;
	"non-null if intantiation is OK"
	variable Object? instantiatedObject = null;
	
	shared actual void abort( Throwable? reason ) {
		if ( running.compareAndSet( true, false ) ) {
			if ( exists reason ) {
				abortReason = reason;
			}
			else {
				abortReason = Exception( title );
			}
			instantiatedObject = null;
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	shared actual void fill( Object instance ) {
		if ( running.compareAndSet( true, false ) ) {
			abortReason = null;
			instantiatedObject = instance;
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	
	"Runs intantiation. Returns instantiated object or null if some error has been occurred.
	 If errored than `TestOutput` field in returned tupple is non-null.
	 "
	shared Object run( Anything(AsyncFactoryContext) factory ) {
		locker.lock();
		running.set( true );
		try {
			abortReason = null;
			instantiatedObject = null;
			factory( this );
			// await initialization completion
			if ( running.get() ) { condition.await(); }
			if ( exists inst = instantiatedObject ) { return inst; }
			else if ( exists ret = abortReason ) { throw ret; }
			else { throw Exception( title ); }
		}
		finally {
			abortReason = null;
			instantiatedObject = null;
			running.set( false );
			locker.unlock();
		}
	}
	
}
