module sqat::series1::A3_CheckStyle

import Java17ish;
import Message;
import List;
import Exception;
import ParseTree;
import util::FileSystem;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import IO;
import String;


/*

Assignment: detect style violations in Java source code.
Select 3 checks out of this list:  http://checkstyle.sourceforge.net/checks.html
Compute a set[Message] (see module Message) containing 
check-style-warnings + location of  the offending source fragment. 

Plus: invent your own style violation or code smell and write a checker.

Note: since concrete matching in Rascal is "modulo Layout", you cannot
do checks of layout or comments (or, at least, this will be very hard).

JPacman has a list of enabled checks in checkstyle.xml.
If you're checking for those, introduce them first to see your implementation
finds them.

Questions
- for each violation: look at the code and describe what is going on? 
  Is it a "valid" violation, or a false positive?

Tips 

- use the grammar in lang::java::\syntax::Java15 to parse source files
  (using parse(#start[CompilationUnit], aLoc), in ParseTree)
  now you can use concrete syntax matching (as in Series 0)

- alternatively: some checks can be based on the M3 ASTs.

- use the functionality defined in util::ResourceMarkers to decorate Java 
  source editors with line decorations to indicate the smell/style violation
  (e.g., addMessageMarkers(set[Message]))

  
Bonus:
- write simple "refactorings" to fix one or more classes of violations 

*/


public set[Message] doublespaces(loc project, set[Message] result ){
	
	locSet = files(project);
 	for (i <- locSet) {
 		count=0;
 		if(i.extension == "java"){
 			lines = readFileLines(i);
 			for(s <- lines){
 			 	s=replaceAll(s,"\t","");
 				if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := s){
 					continue;
 				}		
	    		else if (/\s{2,}[^\t]/ := s ){ 
					result+=error("DoubleSpace", i );
					count+=1;
				}
			}
		}
		//println("<count> at file <i>");
		
	}
	return result;
}

public set[Message] fileLength(loc project, set[Message] result ){
	
	locSet = files(project);
 	for (i <- locSet) {
 	count=0;	
 		if(i.extension == "java"){
 			lines = readFileLines(i);
 				for(s <- lines){
 					count += 1;
 				}				 				
 		}
 		if (count>100)
 			result+=error("FileLength",  i);
 	}
 	
	return result;
}


public set[Message] lineLength(loc project, set[Message] result){

	locSet = files(project);
 		for (i <- locSet) {
 			count=0;
 			if(i.extension == "java"){
 				lines = readFileLines(i);
 				for(s <- lines){
 					if (size(s)>80){
 						result+=error("LineLength",  i);
 						println("<i>  <s>");
 					}							
 				}
 			}
 		}


return result;

}


public set[Message] uselessVariables(loc project, set[Message] result){

	locSet = files(project);
 		for (i <- locSet) {
 			count=0;
 			
 			if(i.extension == "java"){
 			 			 				list[str] words=[];
 			
 				lines = readFileLines(i);
 				for(s <- lines){
 					if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := s){
 					continue;
 					}
 					else if(/\*(.|[\r\n])*?\*/ := s){
 					continue;
 					}
 					else{
 					words+=split(" ", s);
 					}
 				}
 				for (wordSep<-words){
 					if (/(\W)/:=wordSep){
 						words-=wordSep;
 					}
 					
 				}
 				println(distribution(words));
 				
 			}
 			
 		}
 		
 		return result;
 }




set[MethodDec] allMethods(loc file) 
  = {m | /MethodDec m := parse(#start[CompilationUnit], file,allowAmbiguity=true)};

list[set[Message]] maxCC(loc file) 
  = [space(m) | m <- allMethods(file)];
  		

set[Message] checkStyle(loc project) {
  set[Message] result = {};
  allowAmbiguity=true;
  
  
   	result+=doublespaces(project,result);	
   	result+=fileLength(project,result);
   	result+=lineLength(project,result);
   	result+=uselessVariables(project,result);
   	
  
 	//result3 = [*maxCC(f) | /file(f) <- crawl(project), f.extension == "java"];	
	
	
  
  // to be done
  // implement each check in a separate function called here. 
  
  return result;
}
