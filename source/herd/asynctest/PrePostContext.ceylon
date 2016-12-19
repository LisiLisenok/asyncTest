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
import herd.asynctest.runner {
	TestInfo
}
import herd.asynctest.parameterization {
	TestOutput
}


"Performs initialization or disposing.
 Runs a stream of the prepost functions, provides them with prepost context
 and collects report from all of them."
since( "0.6.0" ) by( "Lis" )
class PrePostContext (
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group
)
{	
	"Contains failed messages. Non-empty if aborted."
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();
	

	"Provides prepost context to clients.  
	 Delegates reporting to `outer` until `stop` called."
	class InternalContext (	
			"Title for the currently run function." PrePostFunction prepostFunction,
			"Test info the test is executed with." shared actual TestInfo testInfo
	) extends ContextBase() satisfies AsyncPrePostContext {
		
		shared actual void abort( Throwable reason, String title ) {
			if ( running.compareAndSet( true, false ) ) {
				value tt = if ( prepostFunction.functionTitle.empty ) then title else
					if ( title.empty ) then prepostFunction.functionTitle
						else prepostFunction.functionTitle + ": " + title;
				outer.outputs.add( TestOutput( TestState.aborted, reason, 0, tt ) );
				signal();
			}
		}
		
		shared actual void proceed() {
			if ( running.compareAndSet( true, false ) ) {
				signal();
			}
		}
		
		"Aborts the context when uncaught exception found."
		shared void abortWithUncaughtException( Thread t, Throwable e )
			=> abort( e, "uncaught exception in child thread." );
		
		"Executes the prepost function on the context."
		shared void execute() {
			try { prepostFunction.run( this ); }
			catch ( Throwable err ) {
				if ( is IncompatibleTypeException | InvocationException err ) {
					abort( err, "incompatible invocation of ``prepostFunction.functionTitle``" );
				}
				else {
					abort( err );
				}
			}
			await();
		}
		
	}

	
	"Runs prepost process. Returns errors if occured."
	shared TestOutput[] run (
		"Functions to be preposted." PrePostFunction[] inits,
		"Info about current test or `null` if prepost is global." TestInfo? testInfo
	) {
		for ( init in inits ) {
			InternalContext context = InternalContext( init, testInfo else init.testInfo );
			if ( !group.execute( context.abortWithUncaughtException, init.timeOutMilliseconds, context.execute ) ) {
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
