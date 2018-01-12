module sqat::series2::A1a_StatCov

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import analysis::m3::Core;
import Relation;
import lang::java::jdt::m3::AST;
import IO;
import ParseTree;
import util::Resources;
import lang::java::jdt::Java;
import lang::java::jdt::JDT;
import lang::java::jdt::JavaADT;
import analysis::graphs::Graph;
import Prelude;
import Set;
import Map;
import List;


/*

Implement static code coverage metrics by Alves & Visser 
(https://www.sig.eu/en/about-sig/publications/static-estimation-test-coverage)


The relevant base data types provided by M3 can be found here:

- module analysis::m3::Core:

rel[loc name, loc src]        M3.declarations;            // maps declarations to where they are declared. contains any kind of data or type or code declaration (classes, fields, methods, variables, etc. etc.)
rel[loc name, TypeSymbol typ] M3.types;                   // assigns types to declared source code artifacts
rel[loc src, loc name]        M3.uses;                    // maps source locations of usages to the respective declarations
rel[loc from, loc to]         M3.containment;             // what is logically contained in what else (not necessarily physically, but usually also)
list[Message]                 M3.messages;                // error messages and warnings produced while constructing a single m3 model
rel[str simpleName, loc qualifiedName]  M3.names;         // convenience mapping from logical names to end-user readable (GUI) names, and vice versa
rel[loc definition, loc comments]       M3.documentation; // comments and javadoc attached to declared things
rel[loc definition, Modifier modifier] M3.modifiers;     // modifiers associated with declared things

- module  lang::java::m3::Core:

rel[loc from, loc to] M3.extends;            // classes extending classes and interfaces extending interfaces
rel[loc from, loc to] M3.implements;         // classes implementing interfaces
rel[loc from, loc to] M3.methodInvocation;   // methods calling each other (including constructors)
rel[loc from, loc to] M3.fieldAccess;        // code using data (like fields)
rel[loc from, loc to] M3.typeDependency;     // using a type literal in some code (types of variables, annotations)
rel[loc from, loc to] M3.methodOverrides;    // which method override which other methods
rel[loc declaration, loc annotation] M3.annotations;

Tips
- encode (labeled) graphs as ternary relations: rel[Node,Label,Node]
- define a data type for node types and edge types (labels) 
- use the solve statement to implement your own (custom) transitive closure for reachability.

Questions:
- what methods are not covered at all?
- how do your results compare to the jpacman results in the paper? Has jpacman improved?
- use a third-party coverage tool (e.g. Clover) to compare your results to (explain differences)


*/


M3 jpacmanM3() = createM3FromEclipseProject(|project://jpacman-framework|);
M3 jpacmanM3test() = createM3FromEclipseProject(|project://jpacman-framework/src/test|);

public int function(){
list[loc] methodsAll=[];
list[loc] methodsExtendFrom=[];
list[loc] methodsExtendTo=[];
rel[loc , loc ] extendClasses;
rel[loc , loc ] overrideMethods;
list[loc]overrideMethodsFrom = [];
list[loc]overrideMethodsTo = [];
list[loc]extendClassesFrom = [];
list[loc]extendClassesTo = [];
list[loc]TransitiveClosureMethodsTo = [];
list[loc]TransitiveClosureMethodsFrom = [];
model=jpacmanM3();
testmodel=jpacmanM3test();
loc name;
//set[loc] m=model.containment[|java+class:///nl/tudelft/jpacman/board/Unit|];
classssssss=classes(model);
extendClasses=model.extends;

overrideMethods=model.methodOverrides;

for(k<-overrideMethods){
	overrideMethodsFrom+=k.from;
	overrideMethodsTo+=k.to;
}
for(k<-extendClasses){
	extendClassesFrom+=k.from;
	extendClassesTo+=k.to;
}

for (i<-extendClassesFrom){
			for(e<-model.containment[i]){
			
			if (e.scheme=="java+method"){			
			 methodsExtendFrom+=e;
			}
		}
		}
		
for (i<-extendClassesTo){
			for(e<-model.containment[i]){
			if (e.scheme=="java+method"){
			 methodsExtendTo+=e;
			}
		}
		}
	
println(methodsAll);
Testclass=classes(testmodel);
		for (i<-classssssss){
			for(e<-model.containment[i]){
			
			if (e.scheme=="java+method"){			
			 //println("CLASS <i> METHOD <e>");
			 methodsAll+=e;
			}
		}
		}
		
		
		println(size(methodsAll));		
		solve(testmodel);
	
		tc=(testmodel.methodInvocation+);
		TransitiveClosureMethodsTo= toList(tc.to);
		TransitiveClosureMethodsFrom=toList(tc.from);
		
		  println(tc);
		  println("________________________________________________");
		
		for (k<-testmodel.methodInvocation){
		//if (k.to.scheme=="java+method"){
			//	println([k]+);
			//println(k);
			
			
			//println(TransitiveClosureMethodsTo);
			//println("________________________________________________");
			
			indexList=indexOf(methodsAll,k.to);
			if (indexList>(-1)){
				methodsAll=delete(methodsAll,indexList);	
			}	
			
			tcList=indexOf(TransitiveClosureMethodsFrom,k.to);
			
			while(tcList>-1){
			name=TransitiveClosureMethodsTo[tcList];
			tcList2=indexOf(methodsAll,name);			
			if (tcList2>(-1)){			
				methodsAll=delete(methodsAll,tcList2);			
			}
			TransitiveClosureMethodsFrom=delete(TransitiveClosureMethodsFrom,tcList);
			TransitiveClosureMethodsTo=delete(TransitiveClosureMethodsTo,tcList);
			
			tcList=indexOf(TransitiveClosureMethodsFrom,k.to);
			
			}
			
			
			
			/**	
			overList=indexOf(overrideMethodsFrom,k.to);
			if(overList>-1){
			name=overrideMethodsTo[overList];
			overList2=indexOf(methodsAll,name);			
			if (overList2>(-1)){			
				methodsAll=delete(methodsAll,overList2);			
			}
			}
			
			
			
			extList=indexOf(methodsExtendFrom,k.to);
			if(overList>-1){
			name=methodsExtendTo[extList];
			extList2=indexOf(methodsAll,name);			
			if (extList2>(-1)){			
				methodsAll=delete(methodsAll,extList2);	
					
			}
			}
			*/
			
			
		//}
		}

		println(size(methodsAll));
		//println(methodsAll);
//methods = [ e | e <- m, e.scheme == "java+method"];
//println(methods);

return 0;
}
