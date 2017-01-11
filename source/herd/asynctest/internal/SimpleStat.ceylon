import java.lang {
	Math
}
import herd.asynctest.benchmark {
	StatisticSummary
}


"Provides thread-unsafe statistic calculations."
since( "0.7.0" ) by( "Lis" )
shared class SimpleStat() {
	
	variable Float minVal = infinity;
	variable Float maxVal = -infinity;
	variable Float meanVal = 0.0;
	variable Float m2Val = 0.0;
	variable Integer sizeVal = 0;
	
	"Minimum of the values that have been statisticaly treated."
	shared Float min => minVal;
	"Maximum of the values that have been statisticaly treated."
	shared Float max => maxVal;
	"Mean calculated within Welford's method of standard deviation computation."
	shared Float mean => meanVal;
	"Second moment used in Welford's method of standard deviation computation."
	shared Float m2 => m2Val;
	"The number of the values that have been statisticaly treated."
	shared Integer size => sizeVal;
	
	
	"Resets accumulated statistic to initial state."
	shared void reset() {
		minVal = infinity;
		maxVal = -infinity;
		meanVal = 0.0;
		m2Val = 0.0;
		sizeVal = 0;
	}
	
	"Returns variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared Float variance => if ( sizeVal > 1 ) then m2Val / ( sizeVal - 1 ) else 0.0;
	
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared Float standardDeviation => Math.sqrt( variance );
	
	"Sample variance is size/(size - 1)*variance."
	shared Float sampleVariance => if ( size > 1 ) then size * variance / ( size - 1 ) else 0.0;
	
	"Sample standard deviation is sqrt(size/(size - 1)*variance)."
	shared Float sampleDeviation => if ( size > 1 ) then Math.sqrt( size.float / ( size - 1 ) * variance ) else 0.0;
	
	"Equals to standardDeviation/sqrt(size)."
	shared Float standardError => if ( size > 1 ) then Math.sqrt( variance / size.float ) else 0.0;
	
	"Equals to sampleStandardDeviation/sqrt(size)."
	shared Float sampleError => if ( size > 1 ) then Math.sqrt( variance / ( size - 1 ).float ) else 0.0;
	
	"Equals to sampleError/mean."
	shared Float relativeSampleError => sampleError / mean;
	
	
	shared void sample( Float val ) {
		minVal = val < minVal then val else minVal;
		maxVal = val > maxVal then val else maxVal;
		Float delta = val - meanVal;
		sizeVal ++;
		meanVal = meanVal + delta / sizeVal;
		m2Val = sizeVal > 1 then m2Val + delta * ( val - meanVal ) else 0.0;
	}
	
	shared StatisticSummary result => StatisticSummary( minVal, maxVal, meanVal, standardDeviation, sizeVal );
	
}
