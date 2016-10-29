import herd.asynctest.internal {
	typeName
}

"Verifies if matching exception has type of `ExceptionType`."
tagged( "Exceptions" ) since( "0.6.0" ) by( "Lis" )
shared class ExceptionHasType<ExceptionType>()
		satisfies Matcher<Throwable>
		given ExceptionType satisfies Throwable
{
	shared actual MatchResult match( Throwable val ) {
		value tCheck = `ExceptionType`;
		return MatchResult( "exception has type ``typeName( tCheck )``", if ( is ExceptionType val ) then true else false );
		
	}
	
	shared actual String string {
		value tCheck = `ExceptionType`;
		return "exception has type <``typeName( tCheck )``>";
	}
}


"Verifies if matching exception has message of `messageCondition`."
tagged( "Exceptions" ) since( "0.6.0" ) by( "Lis" )
shared class ExceptionHasMessage( "The expected message." String messageCondition ) satisfies Matcher<Throwable>
{
	shared actual MatchResult match( Throwable val ) {
		return MatchResult( "excetion has message \"``val.message``\"", val.message == messageCondition );
		
	}
	
	shared actual String string {
		return "expected exception message ``messageCondition``";
	}
}


"Verifies if matching exception has no cause."
tagged( "Exceptions" ) since( "0.6.0" ) by( "Lis" )
shared class ExceptionHasNoCause() satisfies Matcher<Throwable>
{
	shared actual MatchResult match( Throwable val ) {
		return MatchResult( "excetion has no cause", !val.cause exists );
		
	}
	
	shared actual String string {
		return "excetion has no cause";
	}
}


"Verifies if matching exception has any cause."
tagged( "Exceptions" ) since( "0.6.0" ) by( "Lis" )
shared class ExceptionHasCause() satisfies Matcher<Throwable>
{
	shared actual MatchResult match( Throwable val ) {
		return MatchResult( "excetion has cause", val.cause exists );
		
	}
	
	shared actual String string {
		return "excetion has cause";
	}
}
