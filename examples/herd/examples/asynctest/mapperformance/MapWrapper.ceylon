import ceylon.collection {

	MutableMap
}
import java.util {

	AbstractMap
}


"Interface used to wrap Ceylon and Java map to test both by a one code"
interface MapWrapper<Key, Item> given Key satisfies Object {
	shared formal void put( Key key, Item item );
	shared formal Item? get( Key key );
	shared formal void remove( Key key );
	shared formal void clear();
}


"Ceylon map wrapper"
class CeylonMapWrapper<Key, Item>( MutableMap<Key, Item> map )
		satisfies MapWrapper<Key, Item>
		given Key satisfies Object
{
	shared actual Item? get( Key key ) => map.get( key );
	shared actual void put( Key key, Item item ) => map.put( key, item );
	shared actual void remove( Key key ) => map.remove( key );
	shared actual void clear() => map.clear();
}


"Java map wrapper"
class JavaMapWrapper<Key, Item>( AbstractMap<Key, Item> map )
		satisfies MapWrapper<Key, Item>
		given Key satisfies Object
{
	shared actual Item? get( Key key ) => map.get( key );
	shared actual void put( Key key, Item item ) => map.put( key, item );
	shared actual void remove( Key key ) => map.remove( key );
	shared actual void clear() => map.clear();
}
