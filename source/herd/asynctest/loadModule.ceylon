import ceylon.language.meta.declaration {

	Module
}
import ceylon.language.meta {

	modules
}


"Loads ceylon module."
by( "Lis" )
Module? loadModule( "name of loaded module" String name, "version of loaded module" String version )
{
	if ( exists ret = modules.find( name, version ) ) {
		return ret;
	}
	else {
		try {
			ModuleLoader.loadModule( name, version );
			return modules.find( name, version );
		}
		catch ( Throwable err ) {
			return null;
		}
	}	
}
