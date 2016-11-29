import java.util.concurrent.locks {
	ReentrantReadWriteLock,
	Lock
}
import java.lang {
	Math
}

"Statistic summary from some variate values stream."
see( `class StatisticRule`, `class MeterRule` )
by( "Lis" ) since( "0.6.0" )
shared class StatisticSummary (
	"Minimum of the values that have been statisticaly treated."
	shared Float min,
	"Maximum of the values that have been statisticaly treated."
	shared Float max,
	"Mean value."
	shared Float mean,
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared Float standardDeviation,		
	"The number of the values that have been statisticaly treated."
	shared Integer size
) {
	"Variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared Float variance => standardDeviation * standardDeviation;
	
	string => "mean=``Float.format(mean, 0, 3)``, standard deviation=``Float.format(standardDeviation, 0, 3)``, " +
			  "max=``Float.format(max, 0, 3)``, min=``Float.format(min, 0, 3)``, total samples=``size``";
}


"Calculates statistic data for stream of variate values."
by( "Lis" ) since( "0.6.0" )
class StatisticCalculator() {
	"Statistics locker."
	ReentrantReadWriteLock lock = ReentrantReadWriteLock();
	Lock rLock = lock.readLock();
	Lock wLock = lock.writeLock();
	
	"Minimum of the values that have been statisticaly treated."
	variable Float min = infinity;
	"Maximum of the values that have been statisticaly treated."
	variable Float max = -infinity;
	"Mean calculated within Welford's method of standard deviation computation."
	variable Float mean = 0.0;
	"Second moment used in Welford's method of standard deviation computation."
	variable Float m2 = 0.0;
	"The number of the values that have been statisticaly treated."
	variable Integer size = 0;
	
	"Returns variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	Float variance => if ( size > 1 ) then m2 / ( size - 1 ) else 0.0;
	
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	Float standardDeviation => Math.sqrt( variance );
	
	variable StatisticSummary? validStat = null;
	
	
	shared void reset() {
		wLock.lock();
		try {
			validStat = null;
			min = infinity;
			max = -infinity;
			mean = 0.0;
			m2 = 0.0;
			size = 0;
		}
		finally {
			wLock.unlock();
		}
	}
	
	"Statistic summary accumulated up to the query moment."
	see( `function sample` )
	shared StatisticSummary statisticSummary {
		rLock.lock();
		try {
			if ( exists s = validStat ) {
				return s;
			}
			else {
				value s = StatisticSummary( min, max, mean, standardDeviation, size );
				validStat = s;
				return s;
			}
		}
		finally { rLock.unlock(); }
	}
	
	"Thread-safely adds samples to the statistic."
	see( `value statisticSummary` )
	shared void sample( Float* values ) {
		wLock.lock();
		try {
			validStat = null;
			for ( item in values ) {
				size ++;
				if ( item < min ) { min = item; }
				if ( max < item ) { max = item; }
				// Welford's method for mean and variance
				Float delta = item - mean;
				mean += delta / size;
				m2 += delta * ( item - mean );
			}
			if ( size < 2 ) { m2 = 0.0; }
		}
		finally {
			wLock.unlock();	
		}
	}
	
	string => "statistic stream calculation";	
}
