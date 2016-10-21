

"Verifies if matching `map` defines the given key `key`, see `Map.defines`."
tagged( "Streams", "Maps" )
since( "0.4.0" )
by( "Lis" )
shared class DefinesKey<Value>( "Item to check if map defines." Value key )
		satisfies Matcher<Map<Value, Anything>>
		given Value satisfies Object
{
	shared actual MatchResult match( Map<Value, Anything> val )
			=> MatchResult( "map ``stringify( val )`` defines ``stringify( key )``", val.defines( key ) );
	
	shared actual String string => "map defines ``key``";
}


"Verifies if matching `map` contains the given item `item`."
tagged( "Streams", "Maps" )
since( "0.4.0" )
by( "Lis" )
shared class ContainsItem<Value>( "Item to check if map contains." Value item )
		satisfies Matcher<Map<Anything, Value>>
		given Value satisfies Object
{
	shared actual MatchResult match( Map<Anything, Value> val )
			=> MatchResult( "map ``stringify( val )`` contains ``stringify( item )``", val.items.contains( item ) );
	
	shared actual String string => "map contains ``item``";
}


"Verifies if matching `map` contains the given item `item` with the given key `key`.
 Items are compared using operator `==`."
tagged( "Streams", "Maps" )
since( "0.4.0" )
by( "Lis" )
shared class ItemByKey<Value> (
	"Key to look `item` at." Object key,
	"Item to check if map contains under given `key`." Value item
)
		satisfies Matcher<Map<Value, Anything>>
		given Value satisfies Object
{
	shared actual MatchResult match( Map<Value, Anything> val )
			=> MatchResult( string, val.get( key )?.equals( item ) else false );
	
	shared actual String string => "item ``stringify( item )`` by key ``stringify( key )``";
}


"Verifies if matching value is a key in the given `map`, see `Map.defines`."
tagged( "Streams", "Maps" )
since( "0.4.0" )
by( "Lis" )
shared class HasKey<Value>( "Item to check if map defines." Map<Value, Anything> map )
		satisfies Matcher<Value>
		given Value satisfies Object
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "as key ``stringify( val )`` of ``stringify( map )``", map.defines( val ) );
	
	shared actual String string => "as key";
}
