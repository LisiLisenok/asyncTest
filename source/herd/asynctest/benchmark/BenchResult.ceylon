

"Represents results of a one benchmark.  
 Contains execution statistic and some additional results."
tagged( "Result" )
see( `class ParameterResult` )
since( "0.7.0" ) by( "Lis" )
shared interface BenchResult satisfies Statistic
{
	"Additional execution results as map of `title` -> `value`."
	shared formal Map<String, Float | Integer> additional;
}


"Returns string representation of additional results"
since( "0.7.0" ) by( "Lis" )
String stringifyAdditionalResults( BenchResult res ) {
	StringBuilder str = StringBuilder();
	for ( title->val in res.additional ) {
		str.append( "; " );
		str.append( title );
		str.append( "=" );
		switch ( val )
		case ( is Float ) {
			str.append( Float.format( val, 0, 3 ) );
		}
		case ( is Integer ) {
			str.append( val.string );
		}
	}
	return str.string;
}


"Delegates results to a given data."
since( "0.7.0" ) by( "Lis" )
class SimpleResults (
	Statistic stat,
	shared actual Map<String, Float | Integer> additional = emptyMap
)
		satisfies BenchResult
{
	
	shared actual Float max => stat.max;
	
	shared actual Float mean => stat.mean;
	
	shared actual Float min => stat.min;
	
	shared actual Integer size => stat.size;
	
	shared actual Float standardDeviation => stat.standardDeviation;
	
	shared actual Float variance => stat.variance;
	
	shared actual Float sampleVariance => stat.sampleVariance;
	
	shared actual Float sampleDeviation => stat.sampleDeviation;
	
	shared actual Float standardError => stat.standardError;
	
	shared actual Float sampleError => stat.sampleError;
	
	shared actual Float relativeSampleError => stat.relativeSampleError;

}
