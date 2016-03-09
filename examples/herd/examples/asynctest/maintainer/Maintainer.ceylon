import herd.asynctest {

	TestMaintainer,
	TestSummary,
	TestGroup,
	arguments
}
import ceylon.file {

	Nil,
	createFileIfNil,
	File,
	parsePath,
	Reader
}
import ceylon.json {
	JSONObject = Object,
	parse
}


"Path maintainer to store test run data in."
[String] maintainerFilePath = ["..\\timeMaintainer.json"];


"Maintains extremum and sorter test groups.  
 Stores results of the run in a file in json format.  
 In the next run extracts results from the stored file.  
 Sortes test groups according to elapsed time of previous run (the less elapsed time the first).
 "
see( `class Extremum`, `class Sorter` )
by( "Lis" )
arguments( `value maintainerFilePath` )
shared class Maintainer (
	"Path to store test data in." String filePath
)
		satisfies TestMaintainer
{
	
	"given path is to be `File` or `Nil`"
	assert ( is Nil | File fileOrNil = parsePath( filePath ).resource );
	value file = createFileIfNil( fileOrNil );
	
	
	"Reads report from previous test run stored in [[filePath]]."
	JSONObject? previousRunReport() {
		StringBuilder builder = StringBuilder();
		Reader reader = file.Reader();
		while ( exists line = reader.readLine() ) {
			builder.append( line );
		}
		value parsingString = builder.string;
		
		if ( !parsingString.empty, is JSONObject ret = parse( parsingString ) ) {
			return ret;
		}
		else {
			return null;
		}
	}
	
	
	"Reads elapsed times from previous run stored in [[filePath]]
	 and sorts test groups according to elapsed time (the less time the first)."
	shared actual TestGroup[] testRunStarted( TestGroup[] testAssembly ) {
		if ( exists prevReport = previousRunReport() ) {
			value ret = testAssembly.sort (
				( TestGroup first, TestGroup second ) {
					if ( is Integer firstTime = prevReport.get( first.name ) ) {
						if ( is Integer secondTime = prevReport.get( second.name ) ) {
							return firstTime <=> secondTime;
						}
						else {
							return smaller;
						}
					}
					else if ( is Integer secondTime = prevReport.get( second.name ) ) {
						return larger;
					}
					else {
						return first.name <=> second.name;
					}
				}
			);
			return ret;
		}
		else {
			return testAssembly;
		}
	}
	
	
	"Stores elapsed times for each test group."
	shared actual void testRunFinished( Map<TestGroup, TestSummary> results ) {
		value report = JSONObject();
		for ( group->summary in results ) {
			report.put( group.name, summary.overallTestTime );
		}
		value writer = file.Overwriter(); 
		writer.write( report.string );
		writer.flush();
	}
	
}
