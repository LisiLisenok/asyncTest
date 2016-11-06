

"Function which run before or after test."
since( "0.6.0" ) by( "Lis" )
class PrePostFunction (
	"Function to be run." shared Anything(AsyncPrePostContext) run,
	"Timeout." shared Integer timeOutMilliseconds,
	"Title used for reporting, usualy declaration name." shared String functionTitle
) {}


"Function which runs the test."
since( "0.6.0" ) by( "Lis" )
class TestFunction (
	"Function to be run." shared Anything(AsyncTestContext) run,
	"Timeout." shared Integer timeOutMilliseconds,
	"Title used for reporting, usualy declaration name." shared String functionTitle
) {}
