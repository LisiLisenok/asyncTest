

"Indicates the kind of the combinatorial source data."
tagged( "Kind" )
see( `function combinatorial`, `class ArgumentVariants` )
since( "0.7.0" ) by( "Lis" )
shared abstract class CombinatorialKind() {}

"Indicates that the test data has to be zipped."
tagged( "Kind" )
since( "0.7.0" ) by( "Lis" )
shared abstract class ZippedKind() of zippedKind extends CombinatorialKind() {
	string => "zipped combinatorial kind";
}

"Indicates that the test data has to be zipped."
tagged( "Kind" )
since( "0.7.0" ) by( "Lis" )
shared object zippedKind extends ZippedKind() {}

"Indicates that the test data has to be permuted."
tagged( "Kind" )
since( "0.7.0" ) by( "Lis" )
shared abstract class PermutationKind() of permutationKind extends CombinatorialKind() {
	string => "permutation combinatorial kind";
}

"Indicates that the test data has to be permuted."
tagged( "Kind" )
since( "0.7.0" ) by( "Lis" )
shared object permutationKind extends PermutationKind() {}
