import ceylon.file {

	parsePath,
	Nil,
	File,
	createFileIfNil,
	Writer
}


"Reports to a file."
throws( `class AssertionError`, "given path is not a `File` or `Nil`" )
since( "0.3.0" )
by( "Lis" )
shared class CSVReporter (
	"Default chart format." ReportFormat format,
	"Path to the file to be reported to." String path,
	"If `true` file will be overwrited otherwise appended." Boolean overwrite = false
)
	satisfies Reporter
{
	
	"given path is to be `File` or `Nil`"
	assert ( is Nil | File fileOrNil = parsePath( path ).resource );
	value file = createFileIfNil( fileOrNil );
	
	shared actual void report( Chart* charts ) {
		Writer writer;
		if ( overwrite ) {
			writer = file.Overwriter();
		}
		else {
			writer = file.Appender();
		}
		reportChartByLines( format, charts, writer.writeLine );
		writer.flush();
		writer.close();
	}
	
	
	shared actual String string => "CSVReporter with ``format.string``, reports to ``path``, ovewrite is ``overwrite``";
	
}
