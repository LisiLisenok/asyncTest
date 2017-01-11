import java.lang {
	Math
}


"Represents statistic values comparing to another [[StatisticSummary]]."
tagged( "Result" )
see( `class StatisticSummary` )
since( "0.7.0" ) by( "Lis" )
shared final class ComparativeStatistic (
	"Statistic to be compared to [[baseMean]]." shared StatisticSummary stat,
	"Base mean value the [[stat]] is compared to." shared Float baseMean
) {
	
	"Minimum of the values that have been statisticaly treated."
	shared Float min => stat.min;
	
	"Maximum of the values that have been statisticaly treated."
	shared Float max => stat.max;
	
	"Mean value."
	shared Float mean => stat.mean;
	
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared Float standardDeviation => stat.standardDeviation;		
	
	"The number of the values that have been statisticaly treated."
	shared Integer size => stat.size;
	
	"Variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared Float variance => stat.variance;
	
	"Sample variance is size/(size - 1)*variance."
	shared Float sampleVariance => if ( size > 1 ) then size * variance / ( size - 1 ) else 0.0;
	
	"Sample standard deviation is sqrt(size/(size - 1)*variance)."
	shared Float sampleDeviation => if ( size > 1 ) then Math.sqrt( size.float / ( size - 1 ) ) * standardDeviation else 0.0;
	
	"Equals to standardDeviation/sqrt(size)."
	shared Float standardError => if ( size > 1 ) then standardDeviation / Math.sqrt( size.float ) else 0.0;
	
	"Equals to sampleStandardDeviation/sqrt(size)."
	shared Float sampleError => if ( size > 1 ) then standardDeviation / Math.sqrt( ( size - 1 ).float ) else 0.0;
	
	"Equals to sampleError/mean."
	shared Float relativeSampleError => sampleError / mean;

	
	"Mean value relative to `baseMean` in percents."
	shared Integer relativeMean => if ( mean == baseMean ) then 100 else ( mean / baseMean * 100 ).integer;
	
	
	shared actual Boolean equals( Object other ) {
		if ( is ComparativeStatistic other ) {
			return stat == other.stat && baseMean == other.baseMean;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash => stat.hash * 37 + baseMean.integer;
	
	
	shared actual String string => "mean=``Float.format(mean, 0, 3)``, standard deviation=``Float.format(standardDeviation, 0, 3)``, " +
			"max=``Float.format(max, 0, 3)``, min=``Float.format(min, 0, 3)``, total samples=``size``,"+
			"relative mean=``relativeMean``%, base mean=``Float.format(baseMean, 0, 3)``";
	
}
