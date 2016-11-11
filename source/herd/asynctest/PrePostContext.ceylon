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
import java.lang {

	Thread
}


"Performs initialization or disposing.
 Runs a stream of the prepost functions, provides them with prepost context
 and collects report from all of them."
since( "0.6.0" ) by( "Lis" )
class PrePostContext()
{	
	"non-null if aborted"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();


	"Provides prepost context to clients.  
	 Delegates reporting to `outer` until `stop` called."
	class InternalContext (	
			"Title for the currently run function." String currentFunction,
			shared actual TestInfo testInfo
	) extends ContextBase() satisfies AsyncPrePostContext {
		
		"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
		shared ContextThreadGroup group = ContextThreadGroup( "asyncPrePost" );
		
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
		
		shared void abortWithUncaughtException( Thread t, Throwable e )
			=> abort( e, "uncaught exception in child thread." );
		
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
	
	"Runs prepost process. Returns errors if occured."
	shared TestOutput[] run (
		"Functions to be preposted." PrePostFunction[] inits,
		"Info about current test or `null` if prepost is global." TestInfo? testInfo 
	) {
		for ( init in inits ) {
			TestInfo t = testInfo else
				TestInfo( init.prepostDeclaration, [], init.arguments, init.functionTitle, init.timeOutMilliseconds );
			InternalContext context = InternalContext( init.functionTitle, t );
			if ( !context.group.execute( context.abortWithUncaughtException, init.timeOutMilliseconds, runFunction( init, context ) ) ) {
				// timeout!
				value excep = TimeOutException( init.timeOutMilliseconds );
				context.abort( excep, excep.message );
			}
		}
		value ret = outputs.sequence(); 
		outputs.clear();
		return ret;
	}
	
}
