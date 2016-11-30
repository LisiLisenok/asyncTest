import java.util.concurrent.atomic {
	JAtomicReference = AtomicReference,
	JAtomicBoolean = AtomicBoolean,
	JAtomicLong = AtomicLong
}
import java.lang {
	Double
}


"Instantiates corresponding to `Value` atomic. Since comparison is done by identity not equality.
 AtomicReference<Integer> doesn't work!
 "
since( "0.6.0" ) by( "Lis" )
shared Atomic<Element> instantiateAtomic<Element>( Element initial ) {
	
	if ( is Integer i = initial ) {
		value v = AtomicInteger( i );
		if ( is Atomic<Element> ret = v ) {
			return ret;
		}
	}
	else if ( is Float i = initial ) {
		value v = AtomicFloat( i );
		if ( is Atomic<Element> ret = v ) {
			return ret;
		}
	}
	else if ( is Boolean i = initial ) {
		value v = AtomicBoolean( i );
		if ( is Atomic<Element> ret = v ) {
			return ret;
		}
	}
	return AtomicReference<Element>( initial );
}


"Atomic interface."
since( "0.6.0" ) by( "Lis" )
shared interface Atomic<Element> {
	
	"Returns stored value."
	shared formal Element get();
	
	"Sets the value to the given `v`."
	shared formal void set( Element v );
	
	"Atomically sets to the given value and returns the old value."
	shared formal Element getAndSet( "Value to be stored." Element newValue );
	
	"Atomically sets the value to the given updated value if the current value == [[expected]].  
	 Returns `false` if current value is not equal to expected one otherwise returns `true`."
	shared formal Boolean compareAndSet (
		"Value to be compared with current one." Element expected,
		"Value to be stored if [[expected]] == current one." Element newValue
	);
}


since( "0.6.0" ) by( "Lis" )
class AtomicBoolean( Boolean initial ) satisfies Atomic<Boolean>
{
	JAtomicBoolean storage = JAtomicBoolean( initial );
	
	shared actual Boolean compareAndSet( Boolean expected, Boolean newValue )
			=> storage.compareAndSet( expected, newValue );
	
	shared actual Boolean get() => storage.get();
	
	shared actual Boolean getAndSet( Boolean newValue ) => storage.getAndSet( newValue );
	
	shared actual void set( Boolean v ) => storage.set( v );
	
	string => "atomic boolean of '``get()``'";
}


since( "0.6.0" ) by( "Lis" )
class AtomicInteger( Integer initial ) satisfies Atomic<Integer>
{
	JAtomicLong storage = JAtomicLong( initial );
	
	shared actual Boolean compareAndSet( Integer expected, Integer newValue )
			=> storage.compareAndSet( expected, newValue );
	
	shared actual Integer get() => storage.get();
	
	shared actual Integer getAndSet( Integer newValue ) => storage.getAndSet( newValue );
	
	shared actual void set( Integer v ) => storage.set( v );
	
	string => "atomic integer of '``get()``'";
}


since( "0.6.0" ) by( "Lis" )
class AtomicFloat( Float initial ) satisfies Atomic<Float>
{
	JAtomicLong storage = JAtomicLong();
	storage.set( Double.doubleToRawLongBits( initial ) );
	
	shared actual Boolean compareAndSet( Float expected, Float newValue )
			=> storage.compareAndSet( Double.doubleToRawLongBits( expected ), Double.doubleToRawLongBits( newValue ) );
	
	shared actual Float get() => Double.longBitsToDouble( storage.get() );
	
	shared actual Float getAndSet( Float newValue )
			=> Double.longBitsToDouble( storage.getAndSet( Double.doubleToRawLongBits( newValue ) ) );
	
	shared actual void set( Float v ) => storage.set( Double.doubleToRawLongBits( v ) );
	
	string => "atomic float of '``stringify( get() )``'";
}


since( "0.6.0" ) by( "Lis" )
class AtomicReference<Element>( Element initial ) satisfies Atomic<Element>
{
	JAtomicReference<Element> storage = JAtomicReference<Element>( initial );
	
	shared actual Boolean compareAndSet( Element expected, Element newValue )
			=> storage.compareAndSet( expected, newValue );
	
	shared actual Element get() => storage.get();
	
	shared actual Element getAndSet( Element newValue ) => storage.getAndSet( newValue );
	
	shared actual void set( Element v ) => storage.set( v );
	
	string => "atomic reference of '``stringify( get() )``'";
}

