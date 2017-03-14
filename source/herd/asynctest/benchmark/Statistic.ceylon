import java.lang {
	Math
}
import herd.asynctest.internal {
	StatisticSummary,
	StatisticAggregator
}


"Provides statistic data for a stream of variate values."
tagged( "Result" )
see( `class StatisticSummary`, `class StatisticAggregator` )
since( "0.6.0" ) by( "Lis" )
shared interface Statistic {
	
	"Minimum of the values that have been statisticaly treated."
	shared formal Float min;
	
	"Maximum of the values that have been statisticaly treated."
	shared formal Float max;
	
	"Mean value."
	shared formal Float mean;
	
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared formal Float standardDeviation;
			
	"The number of the values that have been statisticaly treated."
	shared formal Integer size;
	
	
	"Variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared default Float variance => standardDeviation * standardDeviation;
	
	"Sample variance is size/(size - 1)*variance."
	shared default Float sampleVariance => if ( size > 1 ) then size * variance / ( size - 1 ) else 0.0;
	
	"Sample standard deviation is sqrt(size/(size - 1)*variance)."
	shared default Float sampleDeviation => if ( size > 1 ) then Math.sqrt( size.float / ( size - 1 ) ) * standardDeviation else 0.0;
	
	"Equals to standardDeviation/sqrt(size)."
	shared default Float standardError => if ( size > 1 ) then standardDeviation / Math.sqrt( size.float ) else 0.0;
	
	"Equals to sampleStandardDeviation/sqrt(size)."
	shared default Float sampleError => if ( size > 1 ) then standardDeviation / Math.sqrt( ( size - 1 ).float ) else 0.0;
	
	"Equals to sampleError/mean."
	shared default Float relativeSampleError => sampleError / mean;
	
}
