import ceylon.test {

	TestState
}
import ceylon.collection {

	ArrayList
}
import herd.asynctest.internal {

	ContextThreadGroup
}
import ceylon.language.meta.model {

	IncompatibleTypeException,
	InvocationException
}


"Performs initialization or disposing."
since( "0.6.0" ) by( "Lis" )
class PrePostContext()
{
	"Group to run functions if timeout specified."
	object group extends ContextThreadGroup<AsyncPrePostContext>( "asyncPrePost" ) {
		shared actual void stopWithError( AsyncPrePostContext c, Throwable err )
			=> c.abort( err, "uncaught exception in child thread." );
	}
	
	"non-null if aborted"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();


	"Provides prepost context to clients.  
	 Delegates reporting to `outer` until `stop` called."
	class InternalContext (	
			"Title for the currently run function." String currentFunction,
			shared actual TestInfo testInfo
	) extends ContextBase() satisfies AsyncPrePostContext {
		
		shared actual void abort( Throwable reason, String title ) {
			if ( running.compareAndSet( true, false ) ) {
				value tt = if ( currentFunction.empty ) then title else
					if ( title.empty ) then currentFunction else currentFunction + ": " + title;
				outer.outputs.add( TestOutput( TestState.aborted, reason, 0, tt ) );
				signal();
			}
		}
		
		shared actual void proceed() {
			if ( running.compareAndSet( true, false ) ) {
				signal();
			}
		}
		
	}
	
	
	"Runs prepost function."
	void runFunction( PrePostFunction init, InternalContext context )() {
		try { init.run( context ); }
		catch ( Throwable err ) {
			if ( is IncompatibleTypeException | InvocationException err ) {
				context.abort( err, "incompatible invocation of ``init.functionTitle``" );
			}
			else {
				context.abort( err );
			}
		}
		context.await();
	}
	
	"Runs prepost function on separated thread and controls timeout."
	void runPrePostOnSeparatedThread( PrePostFunction init, TestInfo testInfo ) {
		InternalContext context = InternalContext( init.functionTitle, testInfo );
		if ( !group.execute( context, init.timeOutMilliseconds, runFunction( init, context ) ) ) {
			// timeout!
			value excep = TimeOutException( init.timeOutMilliseconds );
			context.abort( excep, excep.message );
		}
	}
	
	"Runs prepost process. Returns errors if occured."
	shared TestOutput[] run (
		"Function to be preposted" PrePostFunction[] inits,
		"Info about current test or `null` if prepost is global." TestInfo? testInfo 
	) {
		for ( init in inits ) {
			TestInfo t = testInfo else
				TestInfo( init.prepostDeclaration, [], init.arguments, init.functionTitle, init.timeOutMilliseconds );
			runPrePostOnSeparatedThread( init, t );
		}
		value ret = outputs.sequence(); 
		outputs.clear();
		return ret;
	}
	
}
