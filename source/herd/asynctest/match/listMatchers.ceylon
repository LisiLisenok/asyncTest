import herd.asynctest.internal {

	stringify,
	typeName
}


"Verifies if matching `List` value starts with the given `subList`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class StartsWith<Value>( "Sublist matching value to start with." List<Value> subList )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult (
			"``stringify( val )`` starts with ``stringify( subList )``",
			val.startsWith( subList )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "list of <``typeName( tVal )``> starts with";
	}
}


"Verifies if matching `List` value ends with the given `subList`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class EndsWith<Value>( "Sublist matching value to end with." List<Value> subList )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult (
			"``stringify( val )`` ends with ``stringify( subList )``",
			val.endsWith( subList )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "list of <``typeName( tVal )``> ends with";
	}
}


"Verifies if matching `List` value is beginning point of the given `list`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class Beginning<Value>( "List to start with matching value." List<Value> list )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult( "``stringify( val )`` is beginning of ``stringify( list )``", list.startsWith( val ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "beginning list of <``typeName( tVal )``>";
	}
}


"Verifies if matching `List` value is finishing point of the given `list`."
tagged( "Streams", "List" ) since( "0.4.0" ) by( "Lis" )
shared class Finishing<Value>( "List which is expected to finish with matching value." List<Value> list )
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
		=> MatchResult( "``stringify( val )`` is finishinig of ``stringify( list )``", list.endsWith( val ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "finishing list of <``typeName( tVal )``>";
	}
}


"Verifies if matching `List` value is included in the given `list`.  
 `SearchableList.includes` is used in order to perform the verification.  
 "
tagged( "Streams", "List" ) since( "0.6.0" ) by( "Lis" )
shared class Included<Value> (
	"List which is expected to include matching value." SearchableList<Value> list,
	"The smallet index to consider." Integer from = 0
)
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
			=> MatchResult( "``stringify( val )`` is included in ``stringify( list )``", list.includes( val, from ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "included in SearchableList<``typeName( tVal )``>";
	}
}


"Verifies if matching `List` value is included in the given `list` at the given `index` of the `list`.  
 `SearchableList.includesAt` is used in order to perform the verification.  
 "
tagged( "Streams", "List" ) since( "0.7.0" ) by( "Lis" )
shared class IncludedAt<Value> (
	"The index at which the matching value might occur." Integer index,
	"List which is expected to include matching value." SearchableList<Value> list
)
		satisfies Matcher<List<Value>>
{
	shared actual MatchResult match( List<Value> val )
			=> MatchResult (
				"``stringify( val )`` is included in ``stringify( list )`` at index ``index``",
				list.includesAt( index, val )
			);
	
	shared actual String string {
		value tVal = `Value`;
		return "included in SearchableList<``typeName( tVal )``> at index ``index``";
	}
}


"Verifies if matching value occurs in the given `list` at any index within `from`:`length` segment.  
 `SearchableList.occurs` is used in order to perform the verification.  
 "
tagged( "Streams", "List" ) since( "0.7.0" ) by( "Lis" )
shared class Occured<Value> (
	"List which is expected to include matching value." SearchableList<Value> list,
	"The smallet index to consider." Integer from = 0,
	"The number of indexes to consider." Integer length = list.size - from 
)
		satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` occurs in ``stringify( list )`` within ``from``:``length``",
			list.occurs( val, from, length )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "occurs in SearchableList<``typeName( tVal )``> within ``from``:``length``";
	}
}


"Verifies if matching value occurs in the given `list` at the given `index`.  
 `SearchableList.occursAt` is used in order to perform the verification.  
 "
tagged( "Streams", "List" ) since( "0.7.0" ) by( "Lis" )
shared class OccuredAt<Value> (
	"The index at which the matching value might occur." Integer index,
	"List which is expected to include matching value at the given `index`." SearchableList<Value> list
)
		satisfies Matcher<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` occurs in ``stringify( list )`` at index ``index``",
			list.occursAt( index, val )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "occurs in SearchableList<``typeName( tVal )``> at index ``index``";
	}
}


"Verifies if matching `SearchableList` value includes the given `list`.  
 `SearchableList.includes` is used in order to perform the verification.
 "
tagged( "Streams", "List" ) since( "0.6.0" ) by( "Lis" )
shared class Includes<Value> (
	"List which is expected to be included into matching one." List<Value> list,
	"The smallet index to consider." Integer from = 0
)
		satisfies Matcher<SearchableList<Value>>
{
	shared actual MatchResult match( SearchableList<Value> val )
			=> MatchResult( "``stringify( val )`` includes ``stringify( list )``", val.includes( list, from ) );
	
	shared actual String string {
		value tVal = `Value`;
		return "includes List<``typeName( tVal )``>";
	}
}


"Verifies if matching `SearchableList` value includes the given `list` at the given `index`.  
 `SearchableList.includesAt` is used in order to perform the verification.
 "
tagged( "Streams", "List" ) since( "0.7.0" ) by( "Lis" )
shared class IncludesAt<Value> (
	"The index at which `list` might occur in matching value." Integer index,
	"List which is expected to be included into matching one at the given `index`." List<Value> list
)
		satisfies Matcher<SearchableList<Value>>
{
	shared actual MatchResult match( SearchableList<Value> val )
		=> MatchResult (
			"``stringify( val )`` includes ``stringify( list )`` at index ``index``",
			val.includesAt( index, list )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "includes List<``typeName( tVal )``> at index ``index``";
	}
}


"Verifies if the given `element` occurs in matching `SearchableList` value within `from`:`length` segment.  
 `SearchableList.occurs` is used in order to perform the verification.
 "
tagged( "Streams", "List" ) since( "0.7.0" ) by( "Lis" )
shared class Occurs<Value> (
	"Value which is expected to occur in the matching one at within `from`:`length` segment." Value element,
	"The smallet index to consider." Integer from = 0,
	"The number of indexes to consider. If < 0 every element up to the end of matching list is considered."
	Integer length = -1 
)
		satisfies Matcher<SearchableList<Value>>
{
	shared actual MatchResult match( SearchableList<Value> val )
		=> MatchResult (
			"``stringify( val )`` includes ``stringify( element )``",
			val.occurs( element, from, if ( length < 0 ) then val.size - from else length )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "occurs in List<``typeName( tVal )``>";
	}
}


"Verifies if the given `element` occurs in matching `SearchableList` value at the given `index`.  
 `SearchableList.occursAt` is used in order to perform the verification.
 "
tagged( "Streams", "List" ) since( "0.7.0" ) by( "Lis" )
shared class OccursAt<Value> (
	"The index at which the given `element` might occur in the matching list." Integer index,
	"Value which is expected to occur in the matching one at within `from`:`length` segment." Value element
)
		satisfies Matcher<SearchableList<Value>>
{
	shared actual MatchResult match( SearchableList<Value> val )
		=> MatchResult (
			"``stringify( element )`` occurs in ``stringify( val )`` at index ``index``",
			val.occursAt( index, element )
		);
	
	shared actual String string {
		value tVal = `Value`;
		return "occurs in List<``typeName( tVal )``> at index ``index``";
	}
}
