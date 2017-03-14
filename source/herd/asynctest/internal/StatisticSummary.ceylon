import java.lang {
	Math
}
import herd.asynctest.benchmark {
	Statistic
}


"Statistic summary for a stream of variate values."
tagged( "Result" )
since( "0.6.0" ) by( "Lis" )
shared final class StatisticSummary satisfies Statistic {
	
	shared actual Float min;
	shared actual Float max;
	shared actual Float mean;
	shared actual Float standardDeviation;		
	shared actual Integer size;
	
	"Creates new statistic summary with the given data."
	shared new (
		"Minimum of the values that have been statisticaly treated."
		Float min,
		"Maximum of the values that have been statisticaly treated."
		Float max,
		"Mean value."
		Float mean,
		"Returns standard deviation of the values that have been statisticaly treated.
	  	 Standard deviation is `variance^0.5`."
		Float standardDeviation,		
		"The number of the values that have been statisticaly treated."
		Integer size
	) {
		this.min = min;
		this.max = max;
		this.mean = mean;
		this.standardDeviation = standardDeviation;
		this.size = size;
	}
	
	"Creates new statistic summary by combining two others."
	shared new combined( StatisticSummary first, StatisticSummary second ) {
		this.min = first.min < second.min then first.min else second.min;
		this.max = first.max > second.max then first.max else second.max;
		this.size = first.size + second.size;
		Float firstRatio = first.size.float / size;
		Float secondSize = second.size.float;
		Float secondRatio = secondSize / size;
		this.mean = first.mean * firstRatio + second.mean * secondRatio;
		Float delta = second.mean - first.mean;
		Float m2 = first.variance * ( first.size - 1 ) + second.variance * ( second.size - 1 )
				+ delta * delta * firstRatio * secondSize;
		Float variance => if ( size > 1 ) then m2 / ( size - 1 ) else 0.0;
		this.standardDeviation = Math.sqrt( variance );
	}
	
		
	shared actual Boolean equals( Object other ) {
		if ( is StatisticSummary other ) {
			return min == other.min && max == other.max
				&& mean == other.mean && standardDeviation == other.standardDeviation
				&& size == other.size;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		variable Integer ret = 1;
		ret = min.hash + 37 * ret;
		ret = max.hash + 37 * ret;
		ret = mean.hash + 37 * ret;
		ret = standardDeviation.hash + 37 * ret;
		ret = size + 37 * ret;
		return ret;
	}
	
		
	string => "mean=``Float.format(mean, 0, 3)``, standard deviation=``Float.format(standardDeviation, 0, 3)``, " +
			  "max=``Float.format(max, 0, 3)``, min=``Float.format(min, 0, 3)``, total samples=``size``";
}
