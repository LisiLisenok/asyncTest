
"Returns [[CombinatorialAnnotation]] with [[mixingCombinations]] combinator function.
 I.e. it is shortcut for `\`combinatorial(`function mixingCombinations`)`\`.
 
 Note:  
 * [[zippedSource]] provides variants of [[ZippedKind]].  
 * [[permutationSource]] provides variants of [[PermutationKind]].  
 
 Example:
 		Integer[] firstArgument => [1,2];
 		Integer[] secondArgument => [10,20];
 		String[] signArgument => [\"+\",\"-\"];
 		 
 		async test mixing void testMixing (
 			zippedSource(\`value firstArgument\`) Integer arg1,
 			permutationSource(\`value signArgument\`) String arg2,
 			zippedSource(\`value secondArgument\`) Integer arg3
 		) {...}
 
 In the above example:  
 * [[mixing]] annotation forces to use `mixingCombinations` as variant generator.  
 * First and third argument are zipped.  
 * Second argument is permuted.  
 
 As result four test variants are generated:  
 1. `arg1` = 1, `arg2` = \"+\", `arg3` = 10.
 2. `arg1` = 1, `arg2` = \"-\", `arg3` = 10.
 3. `arg1` = 2, `arg2` = \"+\", `arg3` = 20.
 4. `arg1` = 2, `arg2` = \"-\", `arg3` = 20.  
 
 "
tagged( "Applying combinatorial" )
see( `function combinatorial`, `function mixingCombinations`, `function permutationSource`, `function zippedSource`,
	`function permuting`, `function zipping` )
since( "0.7.0" ) by( "Lis" )
shared annotation CombinatorialAnnotation mixing (
	"Maximum number of failed variants to stop testing. Unlimited if <= 0."
	Integer maxFailedVariants = -1
) => CombinatorialAnnotation( `function mixingCombinations`, maxFailedVariants );


"Returns first permuted kind starting from index `from`."
since( "0.7.0" ) by( "Lis" )
Integer firstPermutedKind( ArgumentVariants[] variants, Integer from ) {
	variable Integer retIndex = from;
	while ( exists arg = variants[retIndex ++], arg.kind === zippedKind ) {}
	return retIndex;
}


"Mixes zip and permutation sources. I.e. some arguments may be provided with [[zippedSource]]
 and the other arguments are provided with [[permutationSource]].  
 
 Generation rule: for each zipped variant every possible permutations are generated.  
 
 See example in [[mixing]].
 "
tagged( "Combinatorial generators" )
see( `function mixing`, `function permutationSource`, `function zippedSource` )
throws( `class AssertionError`, "Argument variant is not of 'zipped' or 'permutation' kind" )
since( "0.7.0" ) by( "Lis" )
shared TestVariantEnumerator mixingCombinations (
	"Variants of the test function arguments." ArgumentVariants[] arguments
) {
	// verify each argument is permutation kind
	for ( item in arguments ) {
		if ( !( item.kind === permutationKind || item.kind === zippedKind ) ) {
			throw AssertionError( "To perform mix combination argument ``item.argument.name`` of test function ``item.testFunction.name`` has to be 'zipped' or 'permutation' kind" );
		}
	}
	
	return MixingEnumerator( arguments );
}
