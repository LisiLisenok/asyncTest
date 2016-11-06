import herd.asynctest {
	AsyncPrePostContext
}
import java.util.concurrent.locks {
	ReentrantLock
}

"Tool for controlling access to a shared resource of `Element` type by multiple threads.  
 
 The resource value is set to `initial` _before_ each test.  
 
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
 "
since( "0.6.0" ) by( "Lis" )
shared class LockAccessRule<Element>( Element | Element() initial ) satisfies TestRule
{
	
	class Box( shared variable Element elem ) {}
	
	variable Box stored = Box( if ( is Element() initial ) then initial() else initial );
	
	variable ReentrantLock lock = ReentrantLock();
	
	
	"Locks the resource and provides access to."
	shared class Lock() satisfies Obtainable {
		Box box = stored;
		variable Boolean locked = true;
		lock.lock();
		"Access to the shared resource."
		shared variable Element element = box.elem;
		lock.unlock();
		
		shared actual void obtain() {
			locked = true;
			lock.lock();
		}
		
		shared actual void release( Throwable? error ) {
			"Access to non-obtained lock."
			assert ( locked );
			box.elem = element;
			locked = false;
			lock.unlock();
		}
		
	}
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void before( AsyncPrePostContext context ) {
		stored = Box( if ( is Element() initial ) then initial() else initial );
		lock = ReentrantLock();
		context.proceed();
	}
	
}
