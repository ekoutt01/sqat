module sqat::series1::A1_SLOC

import IO;
import ParseTree;
import String;
import util::FileSystem;
import List;


/* 

Count Source Lines of Code (SLOC) per file:
- ignore comments
- ignore empty lines

Tips
- use locations with the project scheme: e.g. |project:///jpacman/...|
- functions to crawl directories can be found in util::FileSystem
- use the functions in IO to read source files

Answer the following questions:
- what is the biggest file in JPacman?
- what is the total size of JPacman?
- is JPacman large according to SIG maintainability?
- what is the ratio between actual code and test code size?

Sanity checks:
- write tests to ensure you are correctly skipping multi-line comments
- and to ensure that consecutive newlines are counted as one.
- compare you results to external tools sloc and/or cloc.pl

Bonus:
- write a hierarchical tree map visualization using vis::Figure and 
  vis::Render quickly see where the large files are. 
  (https://en.wikipedia.org/wiki/Treemapping) 

run:
>import sqat::series1::A1_SLOC;
>location=|project://jpacman-framework|;
>sloc(location);

test: location=|project://jpacman-framework/src/test|;
*/



	public int countCommentLines(list[str] file){
	  n = 0;
	  for(s <- file)
	    if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := s)   
	      n +=1;
	      
	  return n;
	}

	public int countBlankLines(list[str] file){
		n = 0;
	  for(s <- file)
	    if(/^[ \t\r\n]*$/ := s)  
	      n +=1;
	  return n;
	}


alias SLOC = map[loc file, int sloc];

SLOC sloc(loc project) {
  SLOC result = ();
  // implement here
  
list[int] clines=[];
list[int] blines=[];
list[int] codeLines=[];
list[value] names=[];
int index=0;

 	 locSet = files(project);
 	for (i <- locSet) {
 		if(i.extension == "java"){
 		lines = readFileLines(i);
 		clines=clines+countCommentLines(lines);
 		blines=blines+countBlankLines(lines);
 		int fileSize = size(lines);
 		int sum=fileSize - (blines[index] + clines[index]);
		codeLines = codeLines + sum;
		//println(i);
		names=names+i;
		println(names[index]);
		print("Lines of Code:");
		println(codeLines[index]);
		print("Comment lines:");
		println(clines[index]);
		print("Black lines:");
		println(blines[index]);
		index=index+1;
		}
	}
	println(" -----------------  ");
	
	int k=0;
	int max=0;
	for (i<-codeLines){
		k=k+i;
		if (i>max){
			max=i;
		}
	}

	println();
	print("Sum of sourcecode: "); 
	println(k);
	
	x=indexOf(codeLines,max);
	
	print("Max file: "); 
	println(names[x]);
	print("with size:");
	println(max);
	
	
  return result;
}