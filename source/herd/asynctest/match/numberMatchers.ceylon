import herd.asynctest.internal {
	stringify
}


"Verifies if matching value is negative."
see( `class IsPositive`, `class IsZero`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsNegative<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is negative", val.negative );
	
	shared actual String string => "is negative";
}


"Verifies if matching value is positive."
see( `class IsNegative`, `class IsZero`, `class IsNotZero` )
tagged( "Numbers" ) since( "0.6.0" ) by( "Lis" )
shared class IsPositive<Value>()
		satisfies Matcher<Value>
		given Value satisfies Number<Value>
{
	shared actual MatchResult match( Value val )
			=> MatchResult( "``stringify( val )`` is positive", val.positive );
	
	shared actual String string => "is positive";
}


"Verifies if matching value is zero."
see( `class IsNegative`, `class IsPositive`, `class IsNotZero` )
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
see( `class IsNegative`, `class IsPositive`, `class IsZero` )
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


