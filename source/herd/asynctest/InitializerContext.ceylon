import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import ceylon.language.meta.model {
	IncompatibleTypeException
}

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


"Performs initialization and stores initialized values."
by( "Lis" )
class InitializerContext() satisfies TestInitContext
{
	
	"locks concurent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();
	
	"initialized values"
	ContainerStorage inits = ContainerStorage();
	
	"`true` if initialization completed"
	AtomicBoolean running = AtomicBoolean( true );
	
	"non-null if aborted"
	variable VariantTestOutput? abortOuts = null;
	
	
	shared actual void abort( Throwable reason, String title ) {
		if ( running.compareAndSet( true, false ) ) {
			inits.dispose();
			String msg = if ( title.empty ) then "initialization" else "inittialization '``title``'";
			abortOuts = VariantTestOutput( [TestOutput( TestState.aborted, reason, 0, msg )], 0 );
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
	
	shared actual void put<Item>( String name, Item item, Anything() dispose )
			=> inits.store( name, Container<Item>( item, dispose ) );
	
	shared actual void addTestRunFinishedCallback( Anything() callback )
			=> inits.addTestRunFinishedCallback( callback );

	
	"Runs initialization process."
	shared InitStorage | VariantTestOutput run( FunctionDeclaration declaration ) {
		if ( declaration.toplevel ) {
			locker.lock();
			try {
				// arguments of initializer from `parameters` annotation
				{Anything*} args = resolveArguments( declaration );
				
				// invoke initialization
				declaration.invoke( [], this, *args );
				// await initialization completion
				if ( running.get() ) { condition.await(); }
				
				if ( exists ret = abortOuts ) { return ret; }
				else { return inits; }
			}
			catch ( Throwable err ) {
				return VariantTestOutput( [TestOutput( TestState.aborted, err, 0, "initialization" )], 0 );
			}
			finally {
				locker.unlock();
			}
		}
		else {
			return VariantTestOutput (
				[TestOutput (
					TestState.aborted,
					IncompatibleTypeException( "initialized function ``declaration`` has to be top level" ),
					0, "initialization"
				)],
				0
			);
		}
	}
	
	
	shared actual String string {
		String compl = if ( running.get() ) then "running" else "completed";
		return "TestInitContext, status: '``compl``'";
	}
	
	
}
