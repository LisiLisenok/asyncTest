

"Returns string representation of number of operations"
since( "0.7.0" ) by( "Lis" )
String stringifyNumberOfOperations( Float numOfOp ) {
	if ( numOfOp > 1.0 ) {
		return numOfOp.integer.string;
	}
	else {
		return Float.format( numOfOp, 0, 2 );
	}
}
