import herd.asynctest {
	AsyncPrePostContext
}
import herd.asynctest.internal {
	MarkerThreadGroup,
	stringify
}
import java.lang {
	Thread,
	ThreadGroup
}
import java.util.concurrent.atomic {
	AtomicLong
}


"The rule which returns an element only if it is requested from the same test which initializes the rule.  
 Otherwise [[TestAccessDenied]] is thrown.  
 Actually, a thread interrupted by timeout or by something else may still be alive and may modify a rule.  
 This way improperly completed test may modify the currently executed test data.  
 `CurrentTestStore` rule is indended to prevent such behaviour throwing [[TestAccessDenied]] exception
 when not owner tries to get stored element.  
 
 > Owner here is the test for which initialization has been performed.  
 > The stored value is reseted by extracted from source value each time the new test is started.  
 "
tagged( "TestRule" ) since( "0.7.0" ) by( "Lis" )
shared class CurrentTestStore<Element>( "Source of the stored value." Element | Element() source ) satisfies TestRule
{
	
	"ID of the currently run test."
	AtomicLong currentTestID = AtomicLong( -1 );
	
	// TODO: has to be volatile!
	"Element stored here."
	variable Element storage = if ( is Element() source ) then source() else source;
	
	"Returns marker group the current thread belongs to."
	MarkerThreadGroup? getMarkerGroup() {
		variable ThreadGroup? gr = Thread.currentThread().threadGroup;
		while ( exists cur = gr ) {
			if ( is MarkerThreadGroup cur ) {
				return cur;
			}
			gr = cur.parent;
		}
		return null;
	}
	
	
	"Returns a value if current test ownes the value or throws [[TestAccessDenied]] exception if not."
	throws( `class TestAccessDenied`, "The `element` is requested from a test which doesn't own this." )
	shared Element element {
		if ( exists marker = getMarkerGroup(), marker.testID == currentTestID.get() ) {
			return storage;
		}
		else {
			throw TestAccessDenied( "``stringify(storage)`` is requested from a test which doesn't own this." );
		}
	}
	
	shared actual void after( AsyncPrePostContext context ) {
		currentTestID.set( -1 );
		context.proceed();
	}
	
	shared actual void before( AsyncPrePostContext context ) {
		storage = if ( is Element() source ) then source() else source;
		currentTestID.set( getMarkerGroup()?.testID else -1 );
		context.proceed();
	}
	
}
