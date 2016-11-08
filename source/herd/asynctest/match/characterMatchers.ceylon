import herd.asynctest.internal {
	stringify
}


"Verifies if matching character is an ISO control character."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsControl()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is control", val.control );
	
	shared actual String string => "is control";
}


"Verifies if matching character is a numeric digit."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsDigit()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is digit", val.digit );
	
	shared actual String string => "is digit";
}


"Verifies if matching character is a letter."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsLetter()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is letter", val.letter );
	
	shared actual String string => "is letter";
}


"Verifies if matching character is a lowercase representation of the character."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsLowercase()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is lowercase", val.lowercase );
	
	shared actual String string => "is lowercase";
}


"Verifies if matching character is a uppercase representation of the character."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsUppercase()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is uppercase", val.uppercase );
	
	shared actual String string => "is uppercase";
}


"Verifies if matching character is a titlecase representation of the character."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsTitlecase()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is titlecase", val.titlecase );
	
	shared actual String string => "is titlecase";
}


"Verifies if matching character is whitespace character."
tagged( "Characters" ) since( "0.6.0" ) by( "Lis" )
shared class IsWhitespace()
		satisfies Matcher<Character>
{
	shared actual MatchResult match( Character val )
			=> MatchResult( "``stringify( val )`` is whitespace", val.whitespace );
	
	shared actual String string => "is whitespace";
}
