module sqat::series1::A2_McCabe

import util::FileSystem;
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
import String;
import analysis::statistics::Frequency;




/*

Construct a distribution of method cylcomatic complexity. 
(that is: a map[int, int] where the key is the McCabe complexity, and the value the frequency it occurs)


Questions:
- which method has the highest complexity (use the @src annotation to get a method's location)

- how does pacman fare w.r.t. the SIG maintainability McCabe thresholds?

- is code size correlated with McCabe in this case (use functions in analysis::statistics::Correlation to find out)? 
  (Background: Davy Landman, Alexander Serebrenik, Eric Bouwers and Jurgen J. Vinju. Empirical analysis 
  of the relationship between CC and SLOC in a large corpus of Java methods 
  and C functions Journal of Software: Evolution and Process. 2016. 
  http://homepages.cwi.nl/~jurgenv/papers/JSEP-2015.pdf)
  
- what if you separate out the test sources?

Tips: 
- the AST data type can be found in module lang::java::m3::AST
- use visit to quickly find methods in Declaration ASTs
- compute McCabe by matching on AST nodes

Sanity checks
- write tests to check your implementation of McCabe

Bonus
- write visualization using vis::Figure and vis::Render to render a histogram.



run:
>import sqat::series1::A2_McCabe;
>Locs=jpacmanASTs();
>cc(Locs);


*/


public int visitMethodsNotesOfFile(Declaration fileNode){
 methodList=returnMethod(fileNode);
 int count=1;
 int k=0;
 int fileComplexity=0;
      	
for(methodNode<-methodList){
	count=1;
	visit(methodNode) {
    	case \if(_,_) : count += 1;
        case \if(_,_,_) : count += 1;
        case \case(_) : count += 1;
        case \do(_,_) : count += 1;
        case \while(_,_) : count += 1;
        case \for(_,_,_) : count += 1;
        case \for(_,_,_,_) : count += 1;
        case \foreach(_,_,_) : count += 1;
        case \try(_,_,_) :count += 1;
        case \try(_,_) :count += 1;
        case \catch(_,_): count += 1;
        case \switch(_,_): count += 1;
                
   };

   
   	print(" (<k>) -\>");
  	print(" <count>");
  	println("  in this file <fileNode.src>, in this method <<methodNode.name>>");
  	k=k+1;
   countC=countC+count;
   nameM=nameM+methodNode.name;
   locF=locF+fileNode.src;
   fileComplexity+=count;
   result+=<fileNode.src,count>;
   }
   return fileComplexity;
}




public list[Declaration] returnMethod(Declaration c){

list[Declaration] methods=[];
visit(c){
	case mthd:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):methods+=[mthd];
}

return methods;


}



set[Declaration] jpacmanASTs() = createAstsFromEclipseProject(|project://jpacman-framework/src/main/java/nl/tudelft/jpacman/Launcher.java|, true); 

alias CC = rel[loc method, int cc];
public list[int] countC=[];
public list[str] nameM=[];
public list[loc] locF=[];

public list[int] linesPerFile=[];
public list[int] complexityPerFile=[];
public  CC result={};


CC cc(set[Declaration] decls) {
  int index=0;
  Locs=jpacmanASTs();
  for(tree <- Locs){
	 complexityPerFile += visitMethodsNotesOfFile(tree);
	 list[str] lines = readFileLines(tree.src);
	 
	 linesPerFile+=size(lines);	
//	 println(" File <tree.src> with <linesPerFile> lines, has complexity <complexityPerFile>");
  }
  maxComplexity=max(countC);
  index=indexOf(countC,maxComplexity);
  name=nameM[index];
  locat=locF[index];
  
  
 
  println("Higher complexity is <maxComplexity> of method <name> in file <locat>" );
  
  println("lines      <linesPerFile>");
  println("complexity <complexityPerFile>");
  
  
  return result;
}

alias CCDist = map[int cc, int freq];

CCDist ccDist(CC cc) {
 CCDist freqList;
 freqList=distribution(cc);
 println(freqList);
  return freqList;
}
