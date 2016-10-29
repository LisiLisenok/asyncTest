
"Function which run before or after test."
since( "0.6.0" ) by( "Lis" )
class PrePostFunction (
	shared Anything(AsyncPrePostContext) run,
	shared Integer timeOutMilliseconds,
	shared String functionTitle
) {}


"Function which runs as test."
since( "0.6.0" ) by( "Lis" )
class TestFunction (
	shared Anything(AsyncTestContext) run,
	shared Integer timeOutMilliseconds,
	shared String functionTitle
) {}
