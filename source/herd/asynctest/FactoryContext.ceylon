import java.util.concurrent.locks {
	Condition,
	ReentrantLock
}
import java.util.concurrent.atomic {
	AtomicBoolean
}
import herd.asynctest.internal {
	ExecutionThread
}
import java.util.concurrent {
	CountDownLatch,
	TimeUnit { milliseconds }
}
import java.lang {
	ThreadGroup
}


"Implementation of [[AsyncFactoryContext]]"
see( `function factory` )
since( "0.6.0" ) by( "Lis" )
class FactoryContext( "Factory declaration title." String factoryTitle )
{
	"Group to run functions if timeout specified."
	ThreadGroup group = ThreadGroup( "asyncfactory" );
	
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
	
	
	class InternalContext() satisfies AsyncFactoryContext{
		AtomicBoolean running = AtomicBoolean( true );
		
		"Stops context. No reporting will be submited to `outer`."
		shared void stop() { running.set( false ); }
		
		shared actual void abort( Throwable reason ) {
			if ( running.compareAndSet( true, false ) ) {
				outer.abort( reason );
			}			
		}
		
		shared actual void fill( Object instance ) {
			if ( running.compareAndSet( true, false ) ) {
				outer.fill( instance );
			}			
		}
	}
	
	
	void abort( Throwable reason ) {
		if ( running.compareAndSet( true, false ) ) {
			abortReason = reason;
			instantiatedObject = null;
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	void fill( Object instance ) {
		if ( running.compareAndSet( true, false ) ) {
			abortReason = null;
			instantiatedObject = instance;
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	
	"Runs the factory function."
	void runFactoryFunction( Anything(AsyncFactoryContext) factory, InternalContext context ) {
		running.set( true );
		abortReason = null;
		instantiatedObject = null;
		try { factory( context ); }
		catch ( Throwable err ) {
			running.set( false );
			instantiatedObject = null;
			abortReason = err;
		}
		// await initialization completion
		if ( running.get() ) { 
			locker.lock();
			try { condition.await(); }
			finally { locker.unlock(); }
		}
	}
	
	"Runs the function with timeout taken into account."
	void runFactoryWithTimeout( Anything(AsyncFactoryContext) factory, Integer timeOutMilliseconds ) {
		CountDownLatch latch = CountDownLatch( 1 );
		InternalContext context = InternalContext();
		ExecutionThread thr = ExecutionThread (
			group, "asyncfactory",
			() {
				try { runFactoryFunction( factory, context ); }
				catch ( Throwable err ) {
					context.abort( err );
				}
				finally {
					context.stop();
					latch.countDown();
				}
			}
		);
		thr.start();
		if ( !latch.await( timeOutMilliseconds, milliseconds ) ) {
			// timeout!
			context.stop();
			try { group.interrupt(); }
			catch ( Throwable err ) {}
			value excep = TimeOutException( timeOutMilliseconds );
			abort( excep );
		}
	}
	
	
	"Runs intantiation. Returns instantiated object or throws if errors."
	shared Object run( Anything(AsyncFactoryContext) factory, Integer timeOutMilliseconds ) {
		try {
			if ( timeOutMilliseconds > 0 ) {
				runFactoryWithTimeout( factory, timeOutMilliseconds );
			}
			else {
				InternalContext context = InternalContext();
				try { runFactoryFunction( factory, context ); }
				catch ( Throwable err ) {
					context.abort( err );
				}
			}
			if ( exists ret = abortReason ) { throw ret; }
			else if ( exists inst = instantiatedObject ) { return inst; }
			else { throw FactoryReturnsNothing( factoryTitle ); }
		}
		finally {
			abortReason = null;
			instantiatedObject = null;
			running.set( false );
		}
	}
	
}
