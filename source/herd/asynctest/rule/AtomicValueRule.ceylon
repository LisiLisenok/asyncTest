import herd.asynctest {
	AsyncPrePostContext
}

import herd.asynctest.internal {
	Atomic,
	instantiateAtomic
}


"Atomic reference on some value which is re-initialized to `initial` value each time the test is started.  
 If `Element` is mutable be careful with proper cleaning after the test - factory function is prefered in this case.  
 "
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class AtomicValueRule<Element>( "Initial value source." Element|Element() initial )
		satisfies TestRule
{
	Atomic<Element> extractElement() => if ( is Element() initial )
		then instantiateAtomic( initial() ) else instantiateAtomic( initial );
	
	CurrentTestStore<Atomic<Element>> storage = CurrentTestStore<Atomic<Element>>( extractElement );

	
	"An `Element` stored in the rule."
	shared Element sense => storage.element.get();
	assign sense => storage.element.set( sense );
	
	"Atomically sets the value to the given updated value if the current value == `expected`.  
	 Returns `false` if current value is not equal to expected one otherwise returns `true`."
	shared Boolean compareAndSet (
		"Value to be compared with current one." Element expected,
		"Value to be stored if `expected` == current one." Element newValue
	) => storage.element.compareAndSet( expected, newValue );
	
	"Atomically sets to the given value and returns the old value."
	shared Element getAndSet( Element newValue ) => storage.element.getAndSet( newValue );
	
	
	shared actual void after( AsyncPrePostContext context ) => storage.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => storage.before( context );
	
}
