import java.lang {
	Math
}
import java.util.concurrent.atomic {
	AtomicReference
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


"Current values of statistic calculations."
by( "Lis" ) since( "0.6.1" )
class StatisticStream (
	"Minimum of the values that have been statisticaly treated."
	shared Float min = infinity,
	"Maximum of the values that have been statisticaly treated."
	shared Float max = -infinity,
	"Mean calculated within Welford's method of standard deviation computation."
	shared Float mean = 0.0,
	"Second moment used in Welford's method of standard deviation computation."
	shared Float m2 = 0.0,
	"The number of the values that have been statisticaly treated."
	shared Integer size = 0
)
{
	"Returns variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared Float variance => if ( size > 1 ) then m2 / ( size - 1 ) else 0.0;
	
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared Float standardDeviation => Math.sqrt( variance );
	
	"Returns new stream with added samples."
	shared StatisticStream addSamples( Float* values ) {
		variable Float min = this.min;
		variable Float max = this.max;
		variable Float mean = this.mean;
		variable Float m2 = this.m2;
		variable Integer size = this.size;
		
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
		
		return StatisticStream( min, max, mean, m2, size );
	}
	
	"Returns summary for this stream."
	shared StatisticSummary summary => StatisticSummary( min, max, mean, standardDeviation, size );
}


"Calculates statistic data for stream of variate values."
see( `class StatisticRule`, `class MeterRule` )
by( "Lis" ) since( "0.6.0" )
class StatisticCalculator() {
	
	AtomicReference<StatisticStream> stat = AtomicReference<StatisticStream>( StatisticStream() ); 
	
	
	"Resets calculator to start statistic collecting from scratch."
	shared void reset() {
		variable StatisticStream s = stat.get();
		StatisticStream emptyStat = StatisticStream();
		while ( !stat.compareAndSet( s, emptyStat ) ) {
			s = stat.get();
		}
	}
	
	"Statistic summary accumulated up to the query moment."
	see( `function sample` )
	shared StatisticSummary statisticSummary => stat.get().summary;
	
	"Thread-safely adds samples to the statistic."
	see( `value statisticSummary` )
	shared void sample( Float* values ) {
		variable StatisticStream sOld = stat.get();
		variable StatisticStream sNew = sOld.addSamples( *values );
		while ( !stat.compareAndSet( sOld, sNew ) ) {
			sOld = stat.get();
			sNew = sOld.addSamples( *values );
		}
	}
	
	string => "statistic stream calculation";
	
}
