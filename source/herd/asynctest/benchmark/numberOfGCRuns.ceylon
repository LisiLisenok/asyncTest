import java.lang.management {
	ManagementFactory
}


"Returns number of GC runs up to now."
Integer numberOfGCRuns() {
	variable Integer numGC = 0;
	for ( gcBean in ManagementFactory.garbageCollectorMXBeans ) { numGC += gcBean.collectionCount; }
	return numGC;
}
