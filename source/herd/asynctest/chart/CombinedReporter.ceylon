
"Reports to a set of reporters"
by( "Lis" )
shared class CombinedReporter( {Reporter*} reporters ) satisfies Reporter {
	
	shared actual void report( Chart[] charts ) {
		for ( reporter in reporters ) {
			reporter.report( charts );
		}
	}
	
	
	shared actual String string {
		StringBuilder strBuilder = StringBuilder();
		variable Integer index = 0;
		Integer lastIndex = reporters.size - 1;
		String delim = ", ";
		for ( rep in reporters ) {
			strBuilder.append( "'" );
			strBuilder.append( rep.string );
			strBuilder.append( "'" );
			if ( index != lastIndex ) {
				strBuilder.append( delim );
			}
			index ++;
		}
		return "CombinedReporter: ``strBuilder.string``";
	}
	
	
}