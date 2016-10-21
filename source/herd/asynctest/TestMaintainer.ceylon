

"Maintaining a test assembly:
 * Notified when test started.
 * May sort test assembly (a list of test groups) execution order.
 * May exclude some tests.
 * Notified when test completed with test summary.
 
 Can be specified using [[maintainer]] annotation.
 
 --------------------------------------------
 "
see( `class TestSummary`, `function maintainer`, `class TestGroup` )
since( "0.5.0" )
by( "Lis" )
shared interface TestMaintainer {
	
	"Test started notification.
	 The notification is sent before all tests of the current maintainer are started.  
	 Has to return a list of test groups in order the groups have to be executed.  
	 Returned group list must include only items contained in original list [[testAssembly]].  
	 Some groups can be excluded from the returned list.   
	 "
	shared default TestGroup[] testRunStarted (
		"Test assembly." TestGroup[] testAssembly
	) => testAssembly;
	
	"Test finished notification.  
	 The notification is sent after all tests of the current maintainer are finished.  
	 "
	shared formal void testRunFinished (
		"Test summary as a map of 'test group' -> 'summary'." Map<TestGroup, TestSummary> results
	);
	
}
