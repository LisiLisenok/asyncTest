import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import java.util.concurrent.locks {

	ReentrantLock,
	Condition
}
import ceylon.language.meta.model {

	IncompatibleTypeException
}
import java.util.concurrent.atomic {

	AtomicBoolean
}


"performs initialization and stores initialized context"
by( "Lis" )
class InitializerContext()
		satisfies TestInitContext
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
	variable InitError? reason = null;
	
	
	shared actual void abort( Throwable reason, String title ) {
		if ( running.compareAndSet( true, false ) ) {
			inits.dispose();
			this.reason = InitError( reason, title );
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
	
	
	"run initialization process"
	shared InitStorage | InitError run( FunctionDeclaration declaration ) {
		if ( declaration.toplevel ) {
			locker.lock();
			try {
				// arguments of initializer from `parameters` annotation
				{Anything*} args = resolveArguments( declaration );
				
				// invoke initialization
				declaration.invoke( [], this, *args );
				// await initialization completion
				if ( running.get() ) { condition.await(); }
				
				if ( exists ret = reason ) { return ret; }
				else { return inits; }
			}
			catch ( Throwable err ) {
				return InitError( err, "init invoking" );
			}
			finally {
				locker.unlock();
			}
		}
		else {
			return InitError (
				IncompatibleTypeException( "initialized function ``declaration`` has to be top level" ),
				"init invoking"
			);
		}
	}
}
