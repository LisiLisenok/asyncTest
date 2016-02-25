
"Testing of time scheduler:  
 * [[Scheduler]] to be tested class.  
   This class allows to schedule some periodic jobs and runs them on separated thread from thread pool.  
   Timer is represented by a series of delays (in milliseconds).  
   Timer notifications: timer fire, timer completed and error.  
 * [[testScheduler]] - test function.  
   Runs testing of [[Scheduler]] behaviour according to list of parameters.
 * [[initScheduler]] - test initialization function.  
   Instantiates [[Scheduler]] and stores it on the context with given name (see [[herd.asynctest::TestInitContext.put]])
 "
by( "Lis" )
shared package herd.examples.asynctest.scheduler;
