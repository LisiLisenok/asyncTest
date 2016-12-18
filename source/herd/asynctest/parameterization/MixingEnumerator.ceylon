import herd.asynctest {
	TestVariantResult
}


"Enumerates mixed variants."
since( "0.6.1" ) by( "Lis" )
class MixingEnumerator( ArgumentVariants[] arguments )
		satisfies TestVariantEnumerator
{
	
	"Returns first permuted kind starting from index `from`."
	Integer firstPermutedKind( ArgumentVariants[] variants, Integer from ) {
		variable Integer retIndex = from;
		while ( exists arg = variants[retIndex], arg.kind === zippedKind ) {
			retIndex ++;
		}
		return retIndex;
	}
	
	Integer size = arguments.size;
	"Currently looked indexes of the variants"
	Array<Integer> indexes = Array<Integer>.ofSize( size, 0 );
	"index of current argument"
	variable Integer currentArgumentIndex = firstPermutedKind( arguments, 0 );
	"indicator that mixing is still alive i.e. zip or permutation is available"
	variable Boolean mixAlive = true;

	
	"Shifts permuted index to next. Returns `false` if no more permutations."
	Boolean shiftNextPermuted() {
		if ( currentArgumentIndex < size ) {
			// shift to next of permuted item
			for ( i in 0 .. currentArgumentIndex ) {
				assert ( exists argAtI = arguments[i] );
				// shift to next argument variant if it is of permutation kind
				if ( argAtI.kind === permutationKind ) {
					assert ( exists indexAtI = indexes[i] );
					if ( argAtI.variants.size > indexAtI + 1 ) {
						indexes[i] = indexAtI + 1;
						return true;
					}
					else {
						// index i is full - reset it to first
						indexes[i] = 0;
						// shift index to 1 at next first permuted
						if ( i == currentArgumentIndex ) {
							// skip zipped kind
							Integer startToLookNext = firstPermutedKind( arguments, currentArgumentIndex + 1 );
							// if next index is not found then permutation has to be completed
							currentArgumentIndex = size;
							// reset next indexes to 1 if permuted kind
							for ( j in startToLookNext : size - startToLookNext ) {
								if ( exists arr = arguments[j], arr.kind === permutationKind, arr.variants.size > 1 ) { 
									// next argument to be permuted is found
									indexes[j] = 1;
									currentArgumentIndex = j;
									return true;
								}
							}
							return false;
						}
					}
				}
			}
		}
		return false;
	}
	
	"Shifts zip indexes to next. Returns `false` if no more zippings."
	Boolean shiftNextZipped() {
		if ( mixAlive ) {
			variable Boolean shifted = false;
			for ( i in 0 : size ) {
				assert ( exists argAtI = arguments[i] );
				if ( argAtI.kind === zippedKind ) {
					// shift next index for zipped kind
					assert ( exists indexAtI = indexes[i] );
					if ( indexAtI < argAtI.variants.size - 1 ) {
						shifted = true;
						indexes[i] = indexAtI + 1;
					}
					else {
						// all zips are exhausted - no more variants available
						shifted =  false;
						break;
					}
				}
				else {
					// for permutation kind just reset index to zero
					indexes[i] = 0;
				}
			}
			return shifted;
		}
		return false;
	}
	
	"Shifts to next element."
	TestVariant|Finished shiftNext() {
		if ( mixAlive ) {
			value ret = TestVariant (
				[], [ for ( i in 0 : size ) getArgument( arguments[i], indexes[i] ) ]
			);
			if ( !shiftNextPermuted() ) {
				mixAlive = shiftNextZipped();
				currentArgumentIndex = mixAlive then firstPermutedKind( arguments, 0 ) else size;
			}
			return ret;
		}
		else {
			return finished;
		}
	}
	
	variable TestVariant|Finished curVariant = shiftNext();
	
	shared actual TestVariant|Finished current => curVariant;
	
	shared actual void moveNext( TestVariantResult result ) {
		curVariant = shiftNext();
	}
	
}
