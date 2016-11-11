import ceylon.language.meta.declaration {
	Module
}
import herd.asynctest {
	AsyncPrePostContext
}


"A file packaged within a module and loaded before all tests started.    
 See `ceylon.language::Resource` for details."
tagged( "SuiteRule" ) since( "0.6.0" ) by( "Lis" )
shared class ResourceRule (
	"Module the resource is to be looked in." Module mod,
	"Path the resource is located at." String path
)
		satisfies SuiteRule & Resource
{
	
	variable Resource? resource = null;
	
	
	"Resource name."
	shared actual String name {
		"Resource has to be loaded before usage."
		assert( exists r = resource );
		return r.name;
	}
	
	"The size of the resource, in bytes."
	shared actual Integer size {
		"Resource has to be loaded before usage."
		assert( exists r = resource );
		return r.size;
	}
	
	"The full path to the resource, expressed as a URI. For a resource packaged within a module archive,
	 this includes both the path to the module archive file, and the path of the resource within the module archive."
	shared actual String uri {
		"Resource has to be loaded before usage."
		assert( exists r = resource );
		return r.uri;
	}
	
	"Retrieves the contents of the resource as a [[String]],
	 using the specified encoding."
	shared actual String textContent( String encoding ) {
		"Resource has to be loaded before usage."
		assert( exists r = resource );
		return r.textContent( encoding );
	}
	
		
	shared actual void dispose( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void initialize( AsyncPrePostContext context ) {
		if ( exists r = mod.resourceByPath( path ) ) {
			resource = r;
			context.proceed();
		}
		else {
			context.abort (
				AssertionError( "Resource ``path`` doesn't exist in ``mod``" ),
				"resource ``path`` doesn't exist"
			);
		}
	}
}
