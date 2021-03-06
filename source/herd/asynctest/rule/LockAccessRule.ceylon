import herd.asynctest {
	AsyncPrePostContext
}
import java.util.concurrent.locks {
	ReentrantLock
}
import java.util.concurrent.atomic {
	AtomicLong
}


"Tool for controlling access to a shared resource of `Element` type by multiple threads.  
 
 The resource value is re-initialized to `initial` _before_ each test.  
 
 To acquire lock and get access to resource use nested class `Lock` which satisfies
 `ceylon.language::Obtainable` interface and is intented to be used within `try` block:
 
 		shared testRule LockAccessRule<Element> lockRule = LockAccessRule<Element>(elem);
 		...
 		value lock = lockRule.Lock();
 		try(lock) {
 			lock.element = modifyElement(lock.element);
 		}
 		...
 		try(lock) {
 			lock.element = anotherModifyElement(lock.element);
 		}
 
 > In order to acquire lock `obtain` has to be called.  
 > In order to release lock `release` has to be called.  
 > Actual value is stored in the resource only when `release` is called.  
 
 If `Element` is mutable be careful with proper cleaning after the test - factory function is prefered in this case.  
 "
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class LockAccessRule<Element> (
	"Initial value source. Value is extracted _before_ each test" Element | Element() initial
)
		satisfies TestRule
{
	
	class Box( shared variable Element elem ) {
		shared AtomicLong lockCountAtomic = AtomicLong( 0 );
		shared AtomicLong unlockCountAtomic = AtomicLong( 0 );
		ReentrantLock locker = ReentrantLock();
		shared void lock() {
			locker.lock();
			lockCountAtomic.incrementAndGet();
		}
		shared void unlock() {
			unlockCountAtomic.incrementAndGet();
			locker.unlock();
		}
		
		string => "lock access rule";
	}
	
	CurrentTestStore<Box> stored = CurrentTestStore<Box> (
		() => Box( if ( is Element() initial ) then initial() else initial )
	);
	
	"Total number of times the lock has been obtained."
	shared Integer lockCount => stored.element.lockCountAtomic.get();
	
	"Total number of times the lock has been released."
	shared Integer unlockCount => stored.element.unlockCountAtomic.get();
	
	
	"Locks the resource and provides access to.  
	 Actual resource is stored when `release` is called, but not when `element` is modified."
	shared class Lock() satisfies Obtainable {
		Box box = stored.element;
		variable Boolean locked = true;
		box.lock();
		"Access to the shared resource."
		shared variable Element element = box.elem;
		box.unlock();
		
		shared actual void obtain() {
			box.lock();
			locked = true;
		}
		
		shared actual void release( Throwable? error ) {
			"Access to non-obtained lock."
			assert ( locked );
			box.elem = element;
			locked = false;
			box.unlock();
		}
		
	}
	
	shared actual void after( AsyncPrePostContext context ) => stored.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => stored.before( context );
	
}
