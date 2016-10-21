

"Reports to console"
since( "0.3.0" )
by( "Lis" )
shared class ConsoleReporter( ReportFormat format ) satisfies Reporter {
	
	shared actual void report( Chart* charts ) => reportChartByLines( format, charts, process.writeLine );
	
	shared actual String string => "ConsoleReporter with ``format.string``";
	
}
