import ceylon.language.meta.model {
	Type
}


"Contains function generic type parameters and arguments."
since( "0.6.0" ) by( "Lis" )
shared final class FunctionParameters (
	"Generic type parameters."
	shared Type<Anything>[] generic,
	"Function arguments."
	shared Anything[] arguments
)
{}
