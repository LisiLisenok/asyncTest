

"Factory submited to factory function in order to perform asynchronous instantiation in initialization of test class.
 When object is instantiated it has to be passed to [[fill]] method.
 If some error has been occurred during instantiation and may be reported using [[abort]] method.  
 
 > The test executor blocks the current thread until one of [[fill]] or [[abort]] method is called.
 "
see( `function factory` )
since( "0.6.0" ) by( "Lis" )
shared interface AsyncFactoryContext
{
	
	"Instance has been created - proceed with the test."
	shared formal void fill( Object instance );
	
	"Aborts instantiation."
	shared formal void abort( Throwable reason );
	
}
