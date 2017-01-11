import ceylon.collection {
	HashMap
}


"Benchmark run result for a set of parameters and benches."
tagged( "Result" )
see( `class ParameterResult` )
since( "0.7.0" ) by( "Lis" )
shared final class Result<Parameter> (
	"Time unit the time has been measured with."
	shared TimeUnit timeUnit,
	"Results for a given parameter value."
	Map<Parameter, ParameterResult<Parameter>> byParameter
)
		satisfies Map<Parameter, ParameterResult<Parameter>>
		given Parameter satisfies Anything[]
{
	
	class BenchMap( Bench<Parameter> bench ) satisfies Map<Parameter, StatisticSummary> {
		
		Map<Parameter, ParameterResult<Parameter>> outerParameters => byParameter;
		
		shared actual Boolean defines( Object key ) => byParameter.get( bench )?.defines( key ) else false;
		
		shared actual StatisticSummary? get( Object key ) => byParameter.get( bench )?.get( key );
		
		shared actual StatisticSummary|Default getOrDefault<Default>( Object key, Default default )
				=> byParameter.get( key )?.get( key ) else default;
		
		shared actual Iterator<Parameter->StatisticSummary> iterator()
			=> object satisfies Iterator<Parameter->StatisticSummary> {
				Iterator<Parameter->ParameterResult<Parameter>> paramIterator = byParameter.iterator();
				
				shared actual <Parameter->StatisticSummary>|Finished next() {
					if ( is <Parameter->ParameterResult<Parameter>> nn = paramIterator.next() ) {
						"Results don't contain specified bench."
						assert( exists ret = nn.item.get( bench ) );
						return Entry( nn.key, ret );
					}
					else {
						return finished;
					}
				}
			};
		
		shared actual Integer size => byParameter.size;
		
		shared actual Boolean empty => byParameter.size == 0;
		
		shared actual BenchMap clone() => this;
		
		shared actual Boolean contains( Object entry ) => byParameter.get( bench )?.contains( entry ) else false;
		
		shared actual Integer hash => 37 * bench.hash + byParameter.hash;
		
		shared actual Boolean equals( Object that ) {
			if ( is BenchMap that ) {
				return bench == that.bench && outerParameters == that.outerParameters;
			}
			else {
				return false;
			}
		}
		
	}
	
	HashMap<Bench<Parameter>, BenchMap> benches = HashMap<Bench<Parameter>, BenchMap>();
	
	
	"Returns results for a specific bench."
	shared Map<Parameter, StatisticSummary> forBench( "Bench the results are asked for." Bench<Parameter> bench ) {
		if ( exists ret = benches.get( bench ) ) {
			return ret;
		}
		else if ( exists f = byParameter.first, f.item.defines( bench ) ){
			BenchMap m = BenchMap( bench );
			benches.put( bench, m );
			return m;
		}
		else {
			return emptyMap;
		}
	}
	
	
	shared actual Boolean defines( Object key ) => byParameter.defines( key );
	
	shared actual ParameterResult<Parameter>? get( Object key ) => byParameter.get( key );
	
	shared actual ParameterResult<Parameter>|Default getOrDefault<Default>( Object key, Default default )
			=> byParameter.getOrDefault<Default>( key, default );
	
	shared actual Iterator<Parameter->ParameterResult<Parameter>> iterator() => byParameter.iterator();
	
	shared actual Integer size => byParameter.size;
	
	shared actual Boolean empty => byParameter.size == 0;
	
	shared actual Result<Parameter> clone() => this;
	
	shared actual Boolean contains( Object entry ) => byParameter.contains( entry );
	
	shared actual Result<Parameter> filterKeys( Boolean(Parameter) filtering )
			=> Result<Parameter>( timeUnit, byParameter.filterKeys( filtering ) );
	
	shared actual Integer hash => 37 + byParameter.hash;
	
	shared actual Boolean equals( Object that ) {
		if ( is Result<Anything> that ) {
			return byParameter == that.byParameter;
		}
		else {
			return false;
		}
	}
	
}
