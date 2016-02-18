package herd.asynctest;

import org.jboss.modules.Module;

import ceylon.modules.jboss.runtime.CeylonModuleLoader;

class ModuleLoader {
    
	static void loadModule( String moduleName, String moduleVersion ) {
		try {
			CeylonModuleLoader cml = (CeylonModuleLoader) Module.getCallerModuleLoader();
			cml.loadModuleSynchronous( moduleName, moduleVersion );
		}
		catch ( Throwable err ) {}
    }
    
}
