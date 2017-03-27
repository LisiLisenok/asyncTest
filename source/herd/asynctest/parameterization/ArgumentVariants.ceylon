import ceylon.language.meta.declaration {
	FunctionOrValueDeclaration,
	FunctionDeclaration
}


"Specifies variants for a test function argument."
tagged( "Combinatorial generators" )
since( "0.7.0" ) by( "Lis" )
shared final class ArgumentVariants (
	"Test function declaration."
	shared FunctionDeclaration testFunction,
	"The test function argument this source provides variants for."
	shared FunctionOrValueDeclaration argument,
	"The variants kind which indicates how to combine this argument with the others."
	shared CombinatorialKind kind,
	"A list of argument variants."
	shared [Anything+] variants 
) {}
