import java.util.concurrent.atomic {
	AtomicReference
}
import herd.asynctest.benchmark {
	StatisticSummary
}
import java.lang {
	Math
}


"Current values of statistic calculations."
since( "0.7.0" ) by( "Lis" )
class StatisticStream {
	
	"Minimum of the values that have been statisticaly treated."
	shared Float min;
	"Maximum of the values that have been statisticaly treated."
	shared Float max;
	"Mean calculated within Welford's method of standard deviation computation."
	shared Float mean;
	"Second moment used in Welford's method of standard deviation computation."
	shared Float m2;
	"The number of the values that have been statisticaly treated."
	shared Integer size;
	
	"New empty stream."
	shared new empty() {
		min = infinity;
		max = -infinity;
		mean = 0.0;
		m2 = 0.0;
		size = 0;
	}
	
	"New stream by the given values."
	shared new withValues( {Float*} values ) {
		variable Float min = infinity;
		variable Float max = -infinity;
		variable Float mean = 0.0;
		variable Float m2 = 0.0;
		variable Integer size = 0;
		
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
		
		this.min = min;
		this.max = max;
		this.mean = mean;
		this.m2 = m2;
		this.size = size;
	}
	
	"New stream by combination of two streams."
	shared new combined( StatisticStream first, StatisticStream second ) {
		Float min = first.min < second.min then first.min else second.min;
		Float max = first.max > second.max then first.max else second.max;
		Integer size = first.size + second.size;
		Float firstRatio = first.size.float / size;
		Float secondSize = second.size.float;
		Float secondRatio = secondSize / size;
		Float mean = first.mean * firstRatio + second.mean * secondRatio;
		Float delta = second.mean - first.mean;
		Float m2 = first.m2 + second.m2 + delta * delta * firstRatio * secondSize;
		
		this.min = min;
		this.max = max;
		this.mean = mean;
		this.m2 = m2;
		this.size = size;
	}
	
	"New stream with precalculated data."
	shared new withData( Float min, Float max, Float mean, Float m2, Integer size ) {
		this.min = min;
		this.max = max;
		this.mean = mean;
		this.m2 = m2;
		this.size = size;
	}
	
	
	"Returns variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared Float variance => if ( size > 1 ) then m2 / ( size - 1 ) else 0.0;
	
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared Float standardDeviation => Math.sqrt( variance );
	
	"New stream with a one value added to this."
	shared StatisticStream sample( Float val ) {
		Float min = val < this.min then val else this.min;
		Float max = val > this.max then val else this.max;
		Float delta = val - this.mean;
		Integer size = this.size + 1;
		Float mean = this.mean + delta / size;
		Float m2 = size > 1 then this.m2 + delta * ( val - mean ) else 0.0;
		return StatisticStream.withData( min, max, mean, m2, size );
	}
	
	"Returns summary for this stream."
	shared StatisticSummary summary => StatisticSummary( min, max, mean, standardDeviation, size );
}


"Calculates statistic data for stream of variate values."
since( "0.6.0" ) by( "Lis" )
shared class StatisticCalculator() {
	
	AtomicReference<StatisticStream> stat = AtomicReference<StatisticStream>( StatisticStream.empty() ); 
	
	
	"Resets calculator to start statistic collecting from scratch."
	shared void reset() {
		variable StatisticStream s = stat.get();
		StatisticStream emptyStat = StatisticStream.empty();
		while ( !stat.compareAndSet( s, emptyStat ) ) {
			s = stat.get();
		}
	}
	
	"Mean calculated within Welford's method of standard deviation computation."
	shared Float mean => stat.get().mean;
	"The number of the values that have been statisticaly treated."
	shared Integer size => stat.get().size;

	
	"Statistic summary accumulated up to the query moment."
	see( `function sample`, `function samples` )
	shared StatisticSummary statisticSummary => stat.get().summary;
	
	"Thread-safely adds a one sample to the statistic."
	see( `value statisticSummary`, `function samples` )
	shared void sample( Float val ) {
		variable StatisticStream sOld = stat.get();
		variable StatisticStream sNew = sOld.sample( val );
		while ( !stat.compareAndSet( sOld, sNew ) ) {
			sOld = stat.get();
			sNew = sOld.sample( val );
		}
	}
	
	"Thread-safely adds samples to the statistic."
	see( `value statisticSummary`, `function sample` )
	shared void samples( {Float*} values ) {
		Integer addedSize = values.size;
		if ( addedSize == 1, exists val = values.first ) {
			sample( val );
		}
		else if ( addedSize > 1 ) {
			StatisticStream sAdd = StatisticStream.withValues( values );
			variable StatisticStream sOld = stat.get();
			variable StatisticStream sNew = StatisticStream.combined( sOld, sAdd );
			while ( !stat.compareAndSet( sOld, sNew ) ) {
				sOld = stat.get();
				sNew = StatisticStream.combined( sOld, sAdd );
			}
		}
	}
	
	string => "statistic stream calculation";
	
}
