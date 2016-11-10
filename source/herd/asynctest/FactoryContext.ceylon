import herd.asynctest.internal {

	ContextThreadGroup
}


"Implementation of [[AsyncFactoryContext]]"
see( `function factory` )
since( "0.6.0" ) by( "Lis" )
class FactoryContext( "Factory declaration title." String factoryTitle )
{
	"Group to run functions if timeout specified."
	object group extends ContextThreadGroup<AsyncFactoryContext>( "asyncFactory" ) {
		shared actual void stopWithError( AsyncFactoryContext c, Throwable err )
			=> c.abort( err );
	}
	
	"non-null if aborted"
	variable Throwable? abortReason = null;
	"non-null if intantiation is OK"
	variable Object? instantiatedObject = null;
	
	
	class InternalContext() extends ContextBase() satisfies AsyncFactoryContext {
		
		shared actual void abort( Throwable reason ) {
			if ( running.compareAndSet( true, false ) ) {
				abortReason = reason;
				instantiatedObject = null;
				signal();
			}			
		}
		
		shared actual void fill( Object instance ) {
			if ( running.compareAndSet( true, false ) ) {
				abortReason = null;
				instantiatedObject = instance;
				signal();
			}			
		}
	}
	
	
	"Runs the factory function."
	void runFactoryFunction( Anything(AsyncFactoryContext) factory, InternalContext context )() {
		abortReason = null;
		instantiatedObject = null;
		try { factory( context ); }
		catch ( Throwable err ) {
			instantiatedObject = null;
			abortReason = err;
		}
		context.await();
	}
	
	"Runs the function on separated thread with timeout taken into account."
	void runFactoryOnSeparatedThread( Anything(AsyncFactoryContext) factory, Integer timeOutMilliseconds ) {
		InternalContext context = InternalContext();
		if ( !group.execute( context, timeOutMilliseconds, runFactoryFunction( factory, context ) ) ) {
			// timeout!
			context.abort( TimeOutException( timeOutMilliseconds ) );
		}
	}
	
	
	"Runs intantiation. Returns instantiated object or throws if errors."
	shared Object run( Anything(AsyncFactoryContext) factory, Integer timeOutMilliseconds ) {
		try {
			runFactoryOnSeparatedThread( factory, timeOutMilliseconds );
			if ( exists ret = abortReason ) { throw ret; }
			else if ( exists inst = instantiatedObject ) { return inst; }
			else { throw FactoryReturnsNothing( factoryTitle ); }
		}
		finally {
			abortReason = null;
			instantiatedObject = null;
		}
	}
	
}
