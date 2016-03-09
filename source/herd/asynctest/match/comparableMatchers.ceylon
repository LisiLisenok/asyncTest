

"Verifies if matching value is greater than given `merit`."
tagged( "Comparators" )
by( "Lis" )
shared class Greater<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
 	shared actual MatchResult match( Value val )
 			=> MatchResult( "``stringify( val )`` > ``stringify( merit )``", val > merit );

 	shared actual String string {
 		value tVal = `Value`;
 		return "greater <``tVal``>";
 	}
}


"Verifies if matching value is less than given `merit`."
tagged( "Comparators" )
by( "Lis" )
shared class Less<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` < ``stringify( merit )``", val < merit );

	shared actual String string {
		value tVal = `Value`;
		return "less <``tVal``>";
	}
}


"Verifies if matching value is less or equal to given `merit`."
tagged( "Comparators" )
by( "Lis" )
shared class LessOrEqual<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` <= ``stringify( merit )``", val <= merit );

	shared actual String string {
		value tVal = `Value`;
		return "less or equal <``tVal``>";
	}
}


"Verifies if matching value is greater or equal to given `merit`."
tagged( "Comparators" )
by( "Lis" )
shared class GreaterOrEqual<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` >= ``stringify( merit )``", val >= merit );

	shared actual String string {
		value tVal = `Value`;
		return "greater or equal <``tVal``>";
	}
}


"Verifies if matching value is within given range of `lower` to `upper` excluding bounds.
 This is equal to greater(lower).and(less(upper))."
tagged( "Comparators" )
by( "Lis" )
shared class Within<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` is within ``stringify( lower )`` to ``stringify( upper )`` excluding bounds",
			val > lower && val < upper
		);

	shared actual String string {
		value tVal = `Value`;
		return "within <``tVal``>";
	}
}


"Verifies if matching value is within given range of `lower` to `upper` including bounds.
 This is equal to greaterOrEqual(lower).and(lessOrEqual(upper))."
tagged( "Comparators" )
by( "Lis" )
shared class Ranged<Value> (
	"Start range." Value lower,
	"End range." Value upper
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
		=> MatchResult (
			"``stringify( val )`` is within ``stringify( lower )`` to ``stringify( upper )`` including bounds",
			val >= lower && val <= upper
		);

	shared actual String string {
		value tVal = `Value`;
		return "range <``tVal``>";
	}
}


"Verifies if matching value is equal to `merit`."
tagged( "Comparators" )
by( "Lis" )
shared class EqualTo<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` == ``stringify( merit )``", ( val <=> merit ) == equal );

	shared actual String string {
		value tVal = `Value`;
		return "equal <``tVal``>";
	}
}


"Verifies if matching value is not equal to `merit`."
tagged( "Comparators" )
by( "Lis" )
shared class NotEqualTo<Value> (
	"Value to compare with matching one." Value merit
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` != ``stringify( merit )``", ( val <=> merit ) != equal );

	shared actual String string {
		value tVal = `Value`;
		return "not equal <``tVal``>";
	}
}


"Verifies if matching value is close to `merit` with the given `tolerance`."
tagged( "Comparators" )
by( "Lis" )
shared class CloseTo<Value> (
	"Value to compare with matching one." Value merit,
	"Tolerance to accept matching." Value tolerance
)
		satisfies Matcher<Value>
		given Value satisfies Comparable<Value> & Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult (
				"``stringify( val )`` is close to ``stringify( merit )`` with tolerance ``tolerance``",
				( val - merit ).magnitude < tolerance
			);

	shared actual String string => "close with tolerance ``tolerance``";
}
