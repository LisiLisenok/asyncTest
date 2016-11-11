import herd.asynctest {
	AsyncPrePostContext
}
import java.lang {
	ThreadLocal
}
import java.util.\ifunction {
	Supplier
}


"Test rule which stores values local to the current thread of execution meaning that each thread or process
 that accesses these values get to see their own copy.  
 
 The rule re-sets the stored value to the initial before _each_ test.    
 
 The rule is like to `ceylon.language.Contextual`:  
		ContextualRule<Integer> intValue = ContextualRule<Integer>(10);
 		
		try (intValue.Using(100)) {
			value current = intValue.get();
		}
 
 Each time when `Using.obtain` is called the current value is stored and refreshed with `newValue`.  
 The stored value is retrieved with calling `Using.release` from common stack for all `Using` instances.  
 
 > [[get]] may return value before [[Using]] evaluation!
 
 If `Element` is mutable be careful with proper cleaning after the test - factory function is prefered in this case.  
 
 "
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class ContextualRule<Element>( "Initial value source." Element | Element() initial )
	satisfies TestRule
{

	class Nil {shared new instance {}}
	
	Element&Object|Nil getElement( Element | Element() source )
		=> if ( exists ret = if ( is Element() source ) then source() else source)
				then ret else Nil.instance;

	
	ThreadLocal<Element&Object|Nil> instantiateLocal()
		=> ThreadLocal.withInitial (
			object satisfies Supplier<Element&Object|Nil> {
				get() => getElement( initial );
			}
		);
	
	variable value threadLocal = instantiateLocal();
	
	class StackItem (
		shared Element&Object|Nil item,
		shared StackItem? previous
	) {}
	
	value localStack = ThreadLocal<StackItem?>();

	
	"Returns the currently stored value."
	shared Element get() {
		value ret = threadLocal.get();
		if ( is Element ret ) {
			return ret;
		}
		else {
			assert( is Element null );
			return null;
		}
	}
	
	"Use the contextual."
	shared class Using( Element | Element() newValue )
			satisfies Obtainable {
		
		shared actual void obtain() {
			localStack.set( StackItem( threadLocal.get(), localStack.get() ) );
			threadLocal.set( getElement( newValue ) );
		}
		
		shared actual void release( Throwable? error ) {
			if ( exists s = localStack.get() ) {
				threadLocal.set( s.item );
				localStack.set( s.previous );
			}
		}
	}
	
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void before( AsyncPrePostContext context ) {
		localStack.set( null );
		threadLocal = instantiateLocal();
		context.proceed();
	}
	
}
