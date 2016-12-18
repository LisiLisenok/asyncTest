

"Returns [[CombinatorialAnnotation]] with [[permutingCombinations]] combinator function.
 I.e. it is shortcut for `\`combinatorial(`function permutingCombinations`)`\`.
 
 Example:
 
 		Integer[] firstArgument => [1,2];
 		Integer[] secondArgument => [10,20,30]; 
 
 		async test permuting void myTest (
 			permutationSource(\`value firstArgument\`) Integer arg1,
 			permutationSource(\`value secondArgument\`) Integer arg2
 		) {...}
 		
 The test will be performed using six test variants:  
 1. `arg1` = 1, `arg2` = 10
 2. `arg1` = 1, `arg2` = 20
 3. `arg1` = 1, `arg2` = 30
 4. `arg1` = 2, `arg2` = 10
 5. `arg1` = 2, `arg2` = 20
 6. `arg1` = 2, `arg2` = 30
 "
tagged( "Applying combinatorial" )
see( `function combinatorial`, `function permutingCombinations`, `function permutationSource`,
	`function zipping`, `function mixing` )
since( "0.6.1" ) by( "Lis" )
shared annotation CombinatorialAnnotation permuting (
	"Maximum number of failed variants to stop testing. Unlimited if <= 0."
	Integer maxFailedVariants = -1
) => CombinatorialAnnotation( `function permutingCombinations`, maxFailedVariants );


"Extracts argument by asserting existing."
since( "0.6.1" ) by( "Lis" )
Anything getArgument( ArgumentVariants? args, Integer? index ) {
	assert ( exists args );
	assert ( exists index );
	return args.variants[index];
}


"Enumerates test variants by all possible combinations from provided `arguments`
 of `ArgumentVariants[]` which provides list of variants for the test function arguments.  
 Each function argument has to be of [[PermutationKind]] kind.  
 
 Note: [[permutationSource]] provides variants of [[PermutationKind]].
 
 See example in [[permuting]]."
tagged( "Combinatorial generators" )
see( `function permuting`, `function permutationSource` )
since( "0.6.1" ) by( "Lis" )
shared TestVariantEnumerator permutingCombinations (
	"Variants of the test function arguments." ArgumentVariants[] arguments
) {
	// verify each argument is permutation kind
	for ( item in arguments ) {
		if ( !( item.kind === permutationKind ) ) {
			throw AssertionError( "To perform permutation combination argument ``item.argument.name`` of test function ``item.testFunction.name`` has to be 'permutation' kind" );
		}
	}
	// variants enumerator
	Integer size = arguments.size;
	Array<Integer> indexes = Array<Integer>.ofSize( size, 0 );
	variable Integer columnIndex = 0;
	return TestVariantIterator (
		() {
			if ( columnIndex < size ) {
				value ret = TestVariant (
					[], [ for ( i in 0 : size ) getArgument( arguments[i], indexes[i] ) ]
				);
				for ( i in 0 .. columnIndex ) {
					assert ( exists currentIndex = indexes[i] );
					assert ( exists currentArg = arguments[i] );
					if ( currentArg.variants.size > currentIndex + 1 ) {
						indexes[i] = currentIndex + 1;
						break;
					}
					else {
						indexes[i] = 0;
						if ( i == columnIndex ) {
							columnIndex ++;
							for ( j in columnIndex : size - columnIndex ) {
								if ( exists arr = arguments[j], arr.variants.size > 1 ) { 
									indexes[j] = 1;
									break;
								}
								columnIndex ++;
							}
							break;
						}
					}
				}
				return ret;
			}
			else {
				return finished;
			}
		},
		-1
	);
}
