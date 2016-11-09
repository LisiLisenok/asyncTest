

"Calculates hash for a sequence of elements."
since( "0.6.0" ) by( "Lis" )
Integer sequenceHash( Anything[] stream, Integer base ) {
	variable Integer ret = 1;
	for ( item in stream ) {
		ret = base * ret + ( item?.hash else base );
	}
	return ret;
}
