
"Reports to a set of reporters"
by( "Lis" )
shared class CombinedReporter( {Reporter*} reporters ) satisfies Reporter {
	
	shared actual void report( Chart[] charts ) {
		for ( reporter in reporters ) {
			reporter.report( charts );
		}
	}
	
}