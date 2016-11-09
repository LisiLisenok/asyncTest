import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import ceylon.language.meta.model {
	Type
}


"Test info provided to initializer / cleaner."
see( `interface AsyncPrePostContext`)
since( "0.6.0" ) by( "Lis" )
shared class TestInfo (
	"Declaration of the test function."
	shared FunctionDeclaration testFunction,
	"Generic type parameters."
	shared Type<Anything>[] parameters,
	"Function arguments."
	shared Anything[] arguments,
	"Test variant name as represented in the test report."
	shared String variantName,
	"Time out in milliseconds for a one test function run, <= 0 if no limit."
	shared Integer timeOutMilliseconds
) {}
