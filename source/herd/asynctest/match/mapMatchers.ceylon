

"Matching `Map` to define the given key `key`, see `Map.defines`."
by( "Lis" )
shared class DefinesKey<Value>( "Item to check if map defines." Value key )
		satisfies Matcher<Map<Value, Anything>>
		given Value satisfies Object
{
	shared actual Matching match( Map<Value, Anything> val ) {
		return	if ( val.defines( key ) )
				then Accepted( "map defines ``key``" )
				else Rejected( "map defines ``key``" );
	}
	
	shared actual String string => "map defines ``key``";
}


"Matching `Map` to contain the given item `item`."
by( "Lis" )
shared class ContainsItem<Value>( "Item to check if map contains." Value item )
		satisfies Matcher<Map<Anything, Value>>
		given Value satisfies Object
{
	shared actual Matching match( Map<Anything, Value> val ) {
		return	if ( val.items.contains( item ) )
				then Accepted( "map contains ``item``" )
				else Rejected( "map contains ``item``" );
	}
	
	shared actual String string => "map contains ``item``";
}


"Matching `Map` to contain the given item `item` with the given key `key`.
 Items are compared using operator `==`."
by( "Lis" )
shared class ItemByKey<Value> (
	"Key to look `item` at." Object key,
	"Item to check if map contains under given `key`." Value item
)
		satisfies Matcher<Map<Value, Anything>>
		given Value satisfies Object
{
	shared actual Matching match( Map<Value, Anything> val ) {
		return	if ( val.get( key )?.equals( item ) else false )
				then Accepted( string )
				else Rejected( string );
	}
	
	shared actual String string => "item ``item`` by key ``key``";
}


"Matching value to be a key in the given `map`, see `Map.defines`."
by( "Lis" )
shared class HasKey<Value>( "Item to check if map defines." Map<Value, Anything> map )
		satisfies Matcher<Value>
		given Value satisfies Object
{
	shared actual Matching match( Value val ) {
		return	if ( map.defines( val ) )
				then Accepted( "as key ``val``" )
				else Rejected( "as key ``val``" );
	}
	
	shared actual String string => "as key";
}
