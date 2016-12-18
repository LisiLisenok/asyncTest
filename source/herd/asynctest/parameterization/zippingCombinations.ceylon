

"Returns [[CombinatorialAnnotation]] with [[zippingCombinations]] combinator function.
 I.e. it is shortcut for `\`combinatorial(`function zippingCombinations`)`\`.  
 
 Example:
 
 		Integer[] firstArgument => [1,2,3];
 		Integer[] secondArgument => [10,20,30]; 
 
 		async test zipping void myTest (
 			zippedSource(\`value firstArgument\`) Integer arg1,
 			zippedSource(\`value secondArgument\`) Integer arg2
 		) {...}
 		
 The test will be performed using three test variants:  
 1. `arg1` = 1, `arg2` = 10
 2. `arg1` = 2, `arg2` = 20
 3. `arg1` = 3, `arg2` = 30
 
 "
tagged( "Applying combinatorial" )
see( `function combinatorial`, `function zippingCombinations`, `function zippedSource`,
	`function permuting`, `function mixing` )
since( "0.6.1" ) by( "Lis" )
shared annotation CombinatorialAnnotation zipping (
	"Maximum number of failed variants to stop testing. Unlimited if <= 0."
	Integer maxFailedVariants = -1
) => CombinatorialAnnotation( `function zippingCombinations`, maxFailedVariants );


"Indicates that iterator finished."
since( "0.6.1" ) by( "Lis" )
abstract class FinishedIndicator() of finishedIndicator {}
object finishedIndicator extends FinishedIndicator() {}


"Enumerates test variants by zipping provided `arguments`
 of `ArgumentVariants[]` which provides list of variants for the test function arguments.  
 Each function argument has to be of [[ZippedKind]] kind.  
 
 Note: [[zippedSource]] provides variants of [[ZippedKind]].
 
 Zipping means that 'n-th' variant is built from each 'n-th' item of the argument lists.  
 The variant list finished at the same time when a one of argument lists finishes.
 If the other lists contain more items then those items are simply ignored.  
 
 See example in [[zipping]].
 "
tagged( "Combinatorial generators" )
see( `function zipping`, `function zippedSource` )
since( "0.6.1" ) by( "Lis" )
shared TestVariantEnumerator zippingCombinations (
	"Variants of the test function arguments." ArgumentVariants[] arguments
) {
	// verify that every argument is zipped combinatorial kind
	for ( item in arguments ) {
		if ( !( item.kind === zippedKind ) ) {
			throw AssertionError( "To perform zip combination argument ``item.argument.name`` of test function ``item.testFunction.name`` has to be 'zipped' kind" );
		}
	}
	// collect data and instantiate enumerator
	value streams = [ for ( item in arguments ) item.variants.iterator() ];
	return TestVariantIterator (
		() {
			value ret = [ for ( item in streams ) let ( n = item.next() ) if ( is Finished n ) then finishedIndicator else n ];
			if ( ret.narrow<FinishedIndicator>().empty ) {
				return TestVariant( [], ret );
			}
			else {
				return finished;
			}
		},
		-1
	);
}
