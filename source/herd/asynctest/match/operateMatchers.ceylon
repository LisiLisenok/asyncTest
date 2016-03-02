

"Maps matching value to another one using `convert` and passes converted to the given `matcher`."
by( "Lis" )
shared class Mapping<From, To>( To convert( From val ), Matcher<To> matcher )
		satisfies Matcher<From>
{
	shared actual Matching match( From val ) {
		return matcher.match( convert( val ) );
	}
	
	shared actual String string {
		value tFrom = `From`;
		value tTo = `To`;
		return "mapping from '``tFrom``' to '``tTo``' and match with '``matcher``'";
	}
}


"Maps matching value if it is not `null` to another one using `convert` and passes converted to the given `matcher`.  
 Rejects matching if value is `null`."
by( "Lis" )
shared class MapIfExists<From, To>( To convert( From&Object val ), Matcher<To> matcher )
		satisfies Matcher<From>
{
	shared actual Matching match( From val ) {
		if ( exists from = val ) {
			return matcher.match( convert( from ) );
		}
		else {
			return Rejected( "``string`` got <null>" );
		}
	}
	
	shared actual String string {
		value tFrom = `From`;
		value tTo = `To`;
		return "map if exists from '``tFrom``' to '``tTo``' and match with '``matcher``'";
	}
}


"Pass value matching to the given `matcher` if the value is not `null`.  
 Rejects matching if the value is `null`."
by( "Lis" )
shared class PassExisted<Value>( Matcher<Value> matcher )
		satisfies Matcher<Value?>
		given Value satisfies Object
{
	shared actual Matching match( Value? val ) {
		if ( exists from = val ) {
			return matcher.match( from );
		}
		else {
			return Rejected( "``string`` got <null>" );
		}
	}
	
	shared actual String string {
		value tValue = `Value`;
		return "map existed value '``tValue``' and match with '``matcher``'";
	}
}


"Matching value to be equal to `merit` using `==`."
by( "Lis" )
shared class EqualObjects<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Object
{
	shared actual Matching match( Value val ) {
		return if ( val == merit ) then Accepted( "``val`` == ``merit``" ) else Rejected( "``val`` == ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "equal objects of '``tVal``'";
	}
}


"Matching value to be equal to `merit` using `===`."
by( "Lis" )
shared class Identical<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Identifiable
{
	shared actual Matching match( Value val ) {
		return if ( val === merit ) then Accepted( "``val`` == ``merit``" ) else Rejected( "``val`` == ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "identical <``tVal``>";
	}
}


"Matching value to be of `Check` type."
by( "Lis" )
shared class IsType<Value, Check>()
		satisfies Matcher<Value>
{
	shared actual Matching match( Value val ) {
		value tCheck = `Check`;
		return	if ( is Check val )
				then Accepted( "``val else "<null>"`` is ``tCheck``" )
				else Rejected( "``val else "<null>"`` is ``tCheck``" );
	}

	shared actual String string {
		value tCheck = `Check`;
		return "is <``tCheck``>";
	}
}


"Matching value to be `null`."
by( "Lis" )
shared class IsNull() satisfies Matcher<Anything>
{
	shared actual Matching match( Anything val ) {
		return	if ( exists t = val )
		then Rejected( "``t`` is not <null>" )
		else Accepted( "is <null>" );
	}
	
	shared actual String string => "is <null>";
}


"Matching value to be not `null`."
by( "Lis" )
shared class IsNotNull() satisfies Matcher<Anything> {
	shared actual Matching match( Anything val ) {
		return	if ( exists t = val )
		then Accepted( "``t`` is not <null>" )
		else Rejected( "is <null>" );
	}

	shared actual String string => "is not <null>";
}


"Matching value to be `true`."
by( "Lis" )
shared class IsTrue() satisfies Matcher<Boolean> {
	shared actual Matching match( Boolean val ) {
		return	if ( val )
		then Accepted( "is <true>" )
		else Rejected( "is <false>" );
	}

	shared actual String string => "is <true>";
}


"Matching value to be `false`."
by( "Lis" )
shared class IsFalse() satisfies Matcher<Boolean> {
	shared actual Matching match( Boolean val ) {
		return	if ( val )
		then Rejected( "is <true>" )
		else Accepted( "is <false>" );
	}

	shared actual String string => "is <false>";
}
