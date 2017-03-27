import herd.asynctest {
	AsyncTestContext
}
import herd.asynctest.internal {
	stringify
}


"Helper to represent parameter."
since( "0.7.0" ) by( "Lis" )
String? stringifyParameter<Parameter>( Parameter param )
		given Parameter satisfies Anything[]
		=> if ( param.size > 1 ) then stringify( param ) else
			if ( exists f = param.first ) then stringify( param.first ) else null;


"Writes absolute results of the benchmarking to the context in format:  
 `bench.title` with `parameter`: mean=`mean value`, dev=`sample deviation value`; error=`sample error value`%
 "
tagged( "Writer" )
see( `function benchmark`, `function writeRelativeToSlowest`, `function writeRelativeToFastest` )
since( "0.7.0" ) by( "Lis" )
shared void writeAbsolute<Parameter>( AsyncTestContext context, Result<Parameter> results )
		given Parameter satisfies Anything[]
{
	String tuShort = " op/" + results.timeUnit.shortString;
	for ( param->paramRes in results ) {
		if ( exists paramStr = stringifyParameter( param ) ) {
			for ( bench->stat in paramRes ) {
				context.succeed (
					"``bench.title`` with `" + paramStr
					+ "`: mean=``stringifyNumberOfOperations( stat.mean )````tuShort``; "
					+ "dev=``stringifyNumberOfOperations( stat.sampleDeviation )````tuShort``; "
					+ "error=``Float.format( stat.relativeSampleError * 100, 0, 2 )``%; "
					+ "loops = ``stat.size``"
					+ stringifyAdditionalResults( stat )
				);
			}
		}
		else {
			for ( bench->stat in paramRes ) {
				context.succeed (
					"``bench.title``: mean=``stringifyNumberOfOperations( stat.mean )````tuShort``; "
					+ "dev=``stringifyNumberOfOperations( stat.sampleDeviation )````tuShort``; "
					+ "error=``Float.format( stat.relativeSampleError * 100, 0, 2 )``%; "
					+ "loops = ``stat.size``"
					+ stringifyAdditionalResults( stat )
				);
			}
		}
	}
}


"Writes relative to the slowest results of the benchmarking to the context in format:  
 `bench.title` with `parameter`: mean=`mean value`, dev=`sample deviation value`, `relative mean value`% to slowest; error=`sample error value`%
 "
tagged( "Writer" )
see( `function benchmark`, `function writeRelativeToFastest`, `function writeAbsolute` )
since( "0.7.0" ) by( "Lis" )
shared void writeRelativeToSlowest<Parameter>( AsyncTestContext context, Result<Parameter> results )
		given Parameter satisfies Anything[]
{
	String tuShort = " op/" + results.timeUnit.shortString;
	for ( param->paramRes in results ) {
		if ( exists paramStr = stringifyParameter( param ) ) {
			for ( bench->stat in paramRes ) {
				context.succeed (
					"``bench.title`` with `" + paramStr
					+ "`: mean=``stringifyNumberOfOperations( stat.mean )````tuShort``; "
					+ "dev=``stringifyNumberOfOperations( stat.sampleDeviation )````tuShort``; "
					+ "``( 100 * ( stat.mean / paramRes.slowestMean ) + 0.5 ).integer``% to slowest; "
					+ "error=``Float.format( stat.relativeSampleError * 100, 0, 2 )``%; "
					+ "loops = ``stat.size``"
					+ stringifyAdditionalResults( stat )
				);
			}
		}
		else {
			for ( bench->stat in paramRes ) {
				context.succeed (
					"``bench.title``: mean=``stringifyNumberOfOperations( stat.mean )````tuShort``; "
					+ "dev=``stringifyNumberOfOperations( stat.sampleDeviation )````tuShort``; "
					+ "``( 100 * ( stat.mean / paramRes.slowestMean ) + 0.5 ).integer``% to slowest; "
					+ "error=``Float.format( stat.relativeSampleError * 100, 0, 2 )``%; "
					+ "loops = ``stat.size``"
					+ stringifyAdditionalResults( stat )
				);
			}
		}
	}
}


"Writes relative to the fastest results of the benchmarking to the context in format:  
 `bench.title` with `parameter`: mean=`mean value`; dev=`sample deviation value`; `relative mean value`% to fastest; error=`sample error value`%
 "
tagged( "Writer" )
see( `function benchmark`, `function writeRelativeToSlowest`, `function writeAbsolute` )
since( "0.7.0" ) by( "Lis" )
shared void writeRelativeToFastest<Parameter>( AsyncTestContext context, Result<Parameter> results )
		given Parameter satisfies Anything[]
{
	String tuShort = " op/" + results.timeUnit.shortString;
	for ( param->paramRes in results ) {
		if ( exists paramStr = stringifyParameter( param ) ) {
			for ( bench->stat in paramRes ) {
				context.succeed (
					"``bench.title`` with `" + paramStr
					+ "`: mean=``stringifyNumberOfOperations( stat.mean )````tuShort``; "
					+ "dev=``stringifyNumberOfOperations( stat.sampleDeviation )````tuShort``; "
					+ "``( 100 * ( stat.mean / paramRes.fastestMean ) + 0.5 ).integer``% to fastest; "
					+ "error=``Float.format( stat.relativeSampleError * 100, 0, 2 )``%; "
					+ "loops = ``stat.size``"
					+ stringifyAdditionalResults( stat )
				);
			}
		}
		else {
			for ( bench->stat in paramRes ) {
				context.succeed (
					"``bench.title``: mean=``stringifyNumberOfOperations( stat.mean )````tuShort``; "
					+ "dev=``stringifyNumberOfOperations( stat.sampleDeviation )````tuShort``; "
					+ "``( 100 * ( stat.mean / paramRes.fastestMean ) + 0.5 ).integer``% to fastest; "
					+ "error=``Float.format( stat.relativeSampleError * 100, 0, 2 )``%; "
					+ "loops = ``stat.size``"
					+ stringifyAdditionalResults( stat )
				);
			}
		}
	}
}
