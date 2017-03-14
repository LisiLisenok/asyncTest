import herd.asynctest.internal {
	stringify
}


"Verifies if matching value is negative, i.e. is < 0."
see( `class IsPositive`, `class IsNotPositive`, `class IsNotNegative`, `class IsZero`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsNegative<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is negative", val.negative );
	
	shared actual String string => "is negative";
}


"Verifies if matching value is _not_ negative, i.e. is >= 0."
see( `class IsPositive`, `class IsNotPositive`, `class IsNegative`, `class IsZero`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.7.0" ) by( "Lis" )
shared class IsNotNegative<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is not negative", !val.negative );
	
	shared actual String string => "is not negative";
}


"Verifies if matching value is positive, i.e. is > 0."
see( `class IsNegative`, `class IsNotPositive`, `class IsNotNegative`, `class IsZero`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsPositive<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is positive", val.positive );
	
	shared actual String string => "is positive";
}


"Verifies if matching value is not positive, i.e. is <= 0."
see( `class IsNegative`, `class IsPositive`, `class IsNotNegative`, `class IsZero`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.7.0" ) by( "Lis" )
shared class IsNotPositive<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is not positive", !val.positive );
	
	shared actual String string => "is not positive";
}


"Verifies if matching value is zero."
see( `class IsNegative`, `class IsPositive`, `class IsNotPositive`, `class IsNotNegative`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsZero<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is zero", val.sign == 0 );
	
	shared actual String string => "is zero";
}


"Verifies if matching value is not zero."
see( `class IsNegative`, `class IsPositive`, `class IsNotPositive`, `class IsNotNegative`, `class IsZero` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsNotZero<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is not zero", val.sign != 0 );
	
	shared actual String string => "is not zero";
}


"Verifies if matching value is finite."
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
see( `class IsDefined`, `class IsUndefined`, `class IsInfinite` )
shared class IsFinite()
		satisfies Matcher<Float>
{
	shared actual MatchResult match( Float val )
			=> MatchResult( "``stringify( val )`` is finite", val.finite );
	
	shared actual String string => "is finite";
}


"Verifies if matching value is infinite."
see( `class IsDefined`, `class IsUndefined`, `class IsFinite` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsInfinite()
		satisfies Matcher<Float>
{
	shared actual MatchResult match( Float val )
			=> MatchResult( "``stringify( val )`` is infinite", val.infinite );
	
	shared actual String string => "is infinite";
}


"Verifies if matching value is undefined i.e. is not a number or NaN."
see( `class IsDefined`, `class IsFinite`, `class IsInfinite` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsUndefined()
		satisfies Matcher<Float>
{
	shared actual MatchResult match( Float val )
			=> MatchResult( "``stringify( val )`` is undefined", val.undefined );
	
	shared actual String string => "is undefined";
}


"Verifies if matching value is defined i.e. is not NaN."
see( `class IsUndefined`, `class IsFinite`, `class IsInfinite` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsDefined()
		satisfies Matcher<Float>
{
	shared actual MatchResult match( Float val )
			=> MatchResult( "``stringify( val )`` is defined", !val.undefined );
	
	shared actual String string => "is defined";
}


"Verifies if matching integer is even, i.e. if exists number that i=2*k."
tagged( "Numbers" ) since( "0.7.0" ) by( "Lis" )
shared class IsEven() satisfies Matcher<Integer>
{
	shared actual MatchResult match( Integer val )
			=> MatchResult( "``stringify( val )`` is even", val.even );
	
	shared actual String string => "is even";
}


"Verifies if matching integer is odd, i.e. if exists number that i=2*k+1."
tagged( "Numbers" ) since( "0.7.0" ) by( "Lis" )
shared class IsOdd() satisfies Matcher<Integer>
{
	shared actual MatchResult match( Integer val )
			=> MatchResult( "``stringify( val )`` is odd", !val.even );
	
	shared actual String string => "is odd";
}


"Verifies if matching value is close to `merit` with the given `tolerance`."
tagged( "Numbers" ) see( `class EqualTo` )
since( "0.4.0" ) by( "Lis" )
shared class CloseTo<Value> (
	"Value to compare with matching one." Value merit,
	"Tolerance to accept matching." Value tolerance
)
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
		{
	shared actual MatchResult match( Value val )
			=> MatchResult (
		"``stringify( val )`` is close to ``stringify( merit )`` with tolerance of ``tolerance``",
		( val - merit ).magnitude < tolerance
	);
	
	shared actual String string => "close with tolerance ``tolerance``";
}
