import herd.asynctest {

	async
}


"
 Comparative Ceylon vs Java performance test on HashMap and TreeMap.  
 
 #### Test functions:
 * [[CeylonJavaMapMicrobenchmark.hashMap]] - Ceylon vs Java HashMap test
 * [[CeylonJavaMapMicrobenchmark.treeMap]] - Ceylon vs Java TreeMap test
 
 #### Test strategy
 1. `String` keys and `Integer` items are used.
 2. Operations to be tested: `put`, `get`, `remove`.
 3. Given: total number of items in the map, percent of get / removed items.
 4. For the total number of items `put` operation is performed using `\"value\"+index.string` key and 'index' item.
    Operation time is measured.
 5. For the percented number of items `get` operation is performed. Operation time is measured.
 6. For the percented number of items `remove` operation is performed. Operation time is measured.
 7. 4 - 6 are repeated for a given number of test repeats. Initial map is cleared and reused for the next repeat.
 8. 3 - 7 are repeated with another total number of items.
 
 #### Output
 Results of the test are reported using charts 'Spent Time vs Total Number Of Items'
 and 'Ceylon to Java Time Ratio vs Total Number Of Items'.
 See [[package herd.asynctest.chart]] with charts description.
 
 "
async
shared package herd.examples.asynctest.mapperformance;
