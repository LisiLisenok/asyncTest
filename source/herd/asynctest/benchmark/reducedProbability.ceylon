

"Reduces probability (second parameter in each tuple) that:
 1. Total sum is 1.0.
 2. Items are sorted by probability.
 3. Second parameter in each returned tuple is a sum of all previous.
    This allows to compare the items with random value
    and to select corresponding item according to the given distribution. 
 "
since( "0.7.0" ) by( "Lis" )
[[Anything(*Parameter), Float]+] reducedProbability<Parameter>( [[Anything(*Parameter), Float]+] source )
		given Parameter satisfies Anything[]
{
	value sortedBenches = source.sort (
		([Anything(*Parameter), Float] first, [Anything(*Parameter), Float] second ) => first[1] <=> second[1]
	);
	variable Float totalProbability = sortedBenches.fold( 0.0 ) (
		( Float partial, [Anything(*Parameter), Float] item ) {
			"Selection probability has to be positive."
			assert( item[1] > 0.0 );
			return partial + item[1];
		}
	);
	variable Float count = 0.0;
	return sortedBenches.collect (
		( [Anything(*Parameter), Float] item ) {
			count += item[1];
			return [item[0], count / totalProbability ];
		}
	);
}