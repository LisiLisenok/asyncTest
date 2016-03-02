

"Matching value to be greater than given `merit`."
by( "Lis" )
shared class Greater<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
 	shared actual Matching match( Value val ) {
 		return if ( val > merit ) then Accepted( "``val`` > ``merit``" ) else Rejected( "``val`` > ``merit``" );
 	}

 	shared actual String string {
 		value tVal = `Value`;
 		return "greater <``tVal``>";
 	}
}


"Matching value to be less than given `merit`."
by( "Lis" )
shared class Less<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return if ( val < merit ) then Accepted( "``val`` < ``merit``" ) else Rejected( "``val`` < ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "less <``tVal``>";
	}
}


"Matching value to be less or equal to given `merit`."
by( "Lis" )
shared class LessOrEqual<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return if ( val > merit ) then Rejected( "``val`` <= ``merit``" ) else Accepted( "``val`` <= ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "less or equal <``tVal``>";
	}
}


"Matching value to be greater or equal to given `merit`."
by( "Lis" )
shared class GreaterOrEqual<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return if ( val < merit ) then Rejected( "``val`` >= ``merit``" ) else Accepted( "``val`` >= ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "greater or equal <``tVal``>";
	}
}


"Matching value to be not within given range `lower` to `upper` excluding bounds.
 This is equal to greater(lower).and(less(upper))."
by( "Lis" )
shared class Within<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return	if ( val > lower && val < upper )
				then Accepted( "``val`` is within ``lower`` to ``upper`` excluding bounds" )
				else Rejected( "``val`` is within ``lower`` to ``upper`` excluding bounds" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "within <``tVal``>";
	}
}


"Matching value to be not within given range `lower` to `upper` including bounds.
 This is equal to greaterOrEqual(lower).and(lessOrEqual(upper))."
by( "Lis" )
shared class Ranged<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return	if ( val >= lower && val <= upper )
		then Accepted( "``val`` is within ``lower`` to ``upper`` including bounds" )
		else Rejected( "``val`` is within ``lower`` to ``upper`` including bounds" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "range <``tVal``>";
	}
}


"Matching value to be equal to `merit`."
by( "Lis" )
shared class EqualTo<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return	if ( ( val <=> merit ) == equal )
				then Accepted( "``val`` == ``merit``" )
				else Rejected( "``val`` == ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "equal <``tVal``>";
	}
}


"Matching value to be not equal to `merit`."
by( "Lis" )
shared class NotEqualTo<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual Matching match( Value val ) {
		return if ( val == merit ) then Rejected( "``val`` != ``merit``" ) else Accepted( "``val`` != ``merit``" );
	}

	shared actual String string {
		value tVal = `Value`;
		return "not equal <``tVal``>";
	}
}


"Matching value to be close to `merit` with the given `tolerance`."
by( "Lis" )
shared class CloseTo<Value> (
	"Value to compare with matching one." Value merit,
	"Tolerance to accept matching." Value tolerance
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value> & Number<Value>
{
	shared actual Matching match( Value val ) {
		return	if ( ( val - merit ).magnitude < tolerance )
				then Accepted( "``val`` close ``merit`` with tolerance ``tolerance``" )
				else Rejected( "``val`` close ``merit`` with tolerance ``tolerance``" );
	}

	shared actual String string => "close with tolerance ``tolerance``";
}
