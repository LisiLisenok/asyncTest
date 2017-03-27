import herd.asynctest.internal {

	ContextThreadGroup
}
import java.lang {
	Thread
}


"Implementation of [[AsyncFactoryContext]].  
 Rule: one factory function - one context."
see( `function factory` )
since( "0.6.0" ) by( "Lis" )
class FactoryContext (
	"Factory declaration title."
	String factoryTitle,
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group
)
		extends ContextBase() satisfies AsyncFactoryContext
{
	
	"non-null if aborted"
	variable Throwable? abortReason = null;
	"non-null if intantiation is OK"
	variable Object? instantiatedObject = null;
		
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
	
	void abortWithUncaughtException( Thread t, Throwable e ) => abort( e );
	
	"Runs the factory function."
	void runFactoryFunction( Anything(AsyncFactoryContext) factory )() {
		abortReason = null;
		instantiatedObject = null;
		try { factory( this ); }
		catch ( Throwable err ) { abort( err ); }
		await();
	}
	
	
	"Runs intantiation. Returns instantiated object or throws if errors."
	shared Object run( Anything(AsyncFactoryContext) factory, Integer timeOutMilliseconds ) {
		try {
			if ( !group.execute( abortWithUncaughtException, timeOutMilliseconds, runFactoryFunction( factory ) ) ) {
				// timeout!
				abort( TimeOutException( timeOutMilliseconds ) );
			}
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
