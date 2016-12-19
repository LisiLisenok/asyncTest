import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import herd.asynctest.runner {
	TestInfo
}


"Function which run before or after test."
since( "0.6.0" ) by( "Lis" )
class PrePostFunction (
	"Function to be run." shared Anything(AsyncPrePostContext) run,
	"Timeout." shared Integer timeOutMilliseconds,
	"Title used for reporting, usualy declaration name." shared String functionTitle,
	"Declaration of this prepost function." shared FunctionDeclaration prepostDeclaration,
	"Function arguments." shared Anything[] arguments
) {
	shared TestInfo testInfo = TestInfo (
		prepostDeclaration, [], arguments, functionTitle, timeOutMilliseconds
	);
}


"Function which runs the test."
since( "0.6.0" ) by( "Lis" )
class TestFunction (
	"Function to be run." shared Anything(AsyncTestContext) run,
	"Timeout." shared Integer timeOutMilliseconds,
	"Title used for reporting, usualy declaration name." shared String functionTitle
) {}
