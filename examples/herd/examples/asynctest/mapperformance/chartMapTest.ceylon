import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.chart {

	Plotter
}


"Runs map test and stores results in charts corresponding to [[mapTitle]]."
Float[3] | Throwable chartMapTest (
	"Context the test is run on." AsyncTestContext context,
	"Total items in the map." Integer totalItems,
	"Total number of test repeats." Integer repeats,
	"Percent from total used in get / remove tests." Float removePercent,
	"Title of map to retrieve charts from context." String mapTitle,
	"Creating new map test is performed on." MapWrapper<String, Integer> map
	
) {
	
	"total number of items to be > 0"
	assert( totalItems > 0 );
	"attempts to be > 0"
	assert( repeats > 0 );
	
	String putPlotterName = titles.put + titles.titlesDelimiter + mapTitle;
	String getPlotterName = titles.get + titles.titlesDelimiter + mapTitle;
	String removePlotterName = titles.remove + titles.titlesDelimiter + mapTitle;
	
	if ( exists putPlotter = context.get<Plotter>( putPlotterName ),
		exists getPlotter = context.get<Plotter>( getPlotterName ),
		exists removePlotter = context.get<Plotter>( removePlotterName )
	) {
		// test map
		
		variable Integer count = -1;
		variable Float sumPut = 0.0;
		variable Float sumGet = 0.0;
		variable Float sumRemove = 0.0;
		variable Integer start = 0;
		String prefix = "value";
		
		// warming up
		for ( upper in 0 : 100 ) {
			for ( lower in 0 : 10000 ) {}
		}

		while ( count < repeats ) {
			map.clear();
			
			// test put
			start = system.nanoseconds;
			variable Integer putCount = 0; 
			while ( putCount < totalItems ) {
				map.put( prefix + putCount.string, putCount );
				putCount ++;
			}
			if ( count > -1 ) { sumPut += ( system.nanoseconds - start ) / 1000000.0; }
			
			// test get
			value indexies = keyList( prefix, totalItems, removePercent );
			start = system.nanoseconds;
			for ( item in indexies ) {
				map.get( item );
			}
			if ( count > -1 ) { sumGet += ( system.nanoseconds - start ) / 1000000.0; }
			
			// test remove
			start = system.nanoseconds;
			for ( item in indexies ) {
				map.remove( item );
			}
			if ( count > -1 ) { sumRemove += ( system.nanoseconds - start ) / 1000000.0; }
			
			count ++;
		}
		
		// mean times
		sumPut = sumPut / repeats;
		sumGet = sumGet / repeats;
		sumRemove = sumRemove / repeats;
		
		// store tested data
		putPlotter.addPoint( totalItems.float, sumPut );
		getPlotter.addPoint( totalItems.float, sumGet );
		removePlotter.addPoint( totalItems.float, sumRemove );
		
		return [sumPut, sumGet, sumRemove];
	}
	else {
		return Exception( "plotter with name 'XXX-``mapTitle``' doesn't exists" );
	}
}
