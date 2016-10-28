"Contains atomic representations.  
 Since AtomicReference<Integer> doesn't work (especially `compareAndSet` - comparison is done by identity not equality)
 the unified interface and instantiator is here.
 currently works with:
 * Boolean
 * Integer
 * Float
 * Reference to be compared by identity
 "
since( "0.6.0" ) by( "Lis" )
package herd.asynctest.atomic;
