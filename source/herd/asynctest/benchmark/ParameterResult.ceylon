

"Benchmark run result for a given [[parameter]] and a set of benches."
tagged( "Result" )
see( `class Result`, `interface Bench` )
since( "0.7.0" ) by( "Lis" )
shared final class ParameterResult<Parameter> (
	"Parameter the test has been run with." shared Parameter parameter,
	"Results of the run for the given bench." Map<Bench<Parameter>, StatisticSummary> byBenches
)
	satisfies Map<Bench<Parameter>, StatisticSummary>
	given Parameter satisfies Anything[]
{
	
	variable Float? memoizedSlowestMean = null;
	variable Float? memoizedFastestMean = null;
	
	Float findSlowestMean() {
		Float minVal = byBenches.fold<Float>( infinity ) (
			( Float res, <Bench<Parameter>->StatisticSummary> item )
					=> if ( item.item.mean < res ) then item.item.mean else res
		);
		memoizedSlowestMean = minVal;
		return minVal;
	}
	
	Float findFastestMean() {
		Float maxVal = byBenches.fold<Float>( -infinity ) (
			( Float res, <Bench<Parameter>->StatisticSummary> item )
					=> if ( item.item.mean > res ) then item.item.mean else res
		);
		memoizedFastestMean = maxVal;
		return maxVal;
	}

	
	"`true` if item mean equals to `slowestMean`."	
	Boolean filterBySlowest( <Bench<Parameter>->StatisticSummary> item ) => item.item.mean == slowestMean;
	
	"`true` if item mean equals to `fastestMean`."
	Boolean filterByFastest( <Bench<Parameter>->StatisticSummary> item ) => item.item.mean == fastestMean;
	
	
	"Mean value of the slowest benches."
	see( `value slowest` )
	shared Float slowestMean => memoizedSlowestMean else ( memoizedSlowestMean = findSlowestMean() );
	
	"A list of benches which showed the smallest performance, i.e. mean number of operations per second is smallest."
	see( `value slowestMean` )
	shared {<Bench<Parameter>->StatisticSummary>*} slowest => byBenches.filter( filterBySlowest );
	
	"Mean value of the fastest benches."
	see( `value fastest` )
	shared Float fastestMean => memoizedFastestMean else ( memoizedFastestMean = findFastestMean() );
	
	"A list of benches which showed the fastest performance, i.e. mean number of operations per second is largest."
	see( `value fastestMean` )
	shared {<Bench<Parameter>->StatisticSummary>*} fastest => byBenches.filter( filterByFastest );
	
	"Returns map of [[ComparativeStatistic]] related to the given [[benchOrMean]]."
	see( `function relativeToSlowest`, `function relativeToFastest` )
	shared Map<Bench<Parameter>, ComparativeStatistic> relativeTo (
		"Bench or summary statistic to calculate comparative statistic to." Bench<Parameter> | Float benchOrMean
	) {
		if ( exists stat = if ( is Float benchOrMean ) then benchOrMean else get( benchOrMean )?.mean ) {
			return byBenches.mapItems<ComparativeStatistic> (
				(  Bench<Parameter> key, StatisticSummary item ) => ComparativeStatistic( item, stat )
			);
		}
		else {
			return emptyMap;
		}
	}
	
	"Returns map of [[ComparativeStatistic]] related to the slowest bench."
	see( `function relativeTo`, `function relativeToFastest` )
	shared Map<Bench<Parameter>, ComparativeStatistic> relativeToSlowest() => relativeTo( slowestMean );
	
	"Returns map of [[ComparativeStatistic]] related to the fastest bench."
	see( `function relativeToSlowest`, `function relativeTo` )
	shared Map<Bench<Parameter>, ComparativeStatistic> relativeToFastest() => relativeTo( fastestMean );
	
	
	shared actual Boolean defines( Object key ) => byBenches.defines( key );
	
	shared actual StatisticSummary? get( Object key ) => byBenches.get( key );
	
	shared actual StatisticSummary|Default getOrDefault<Default>( Object key, Default default )
		=> byBenches.getOrDefault<Default>( key, default );
	
	shared actual Iterator<Bench<Parameter>->StatisticSummary> iterator() => byBenches.iterator();
	
	shared actual Integer size => byBenches.size;
	
	shared actual Boolean empty => byBenches.size == 0;
	
	shared actual ParameterResult<Parameter> clone() => this;
	
	shared actual Boolean contains( Object entry ) => byBenches.contains( entry );
	
	shared actual ParameterResult<Parameter> filterKeys( Boolean(Bench<Parameter>) filtering )
		=> ParameterResult<Parameter>( parameter, byBenches.filterKeys( filtering ) );
	
	shared actual Integer hash => 37 + byBenches.hash;
	
	shared actual Boolean equals( Object that ) {
		if ( is ParameterResult<Anything> that ) {
			return byBenches == that.byBenches;
		}
		else {
			return false;
		}
	}
	
}
