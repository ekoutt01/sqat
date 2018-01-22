module sqat::series2::A2_CheckArch

import sqat::series2::Dicto;
import lang::java::jdt::m3::Core;
import Message;
import ParseTree;
import IO;
import lang::java::m3::Core;
import analysis::m3::Core;
import Plugin;
import String;



/*

This assignment has two parts:
- write a dicto file (see example.dicto for an example)
  containing 3 or more architectural rules for Pacman
  
- write an evaluator for the Dicto language that checks for
  violations of these rules. 

Part 1  

An example is: ensure that the game logic component does not 
depend on the GUI subsystem. Another example could relate to
the proper use of factories.   

Make sure that at least one of them is violated (perhaps by
first introducing the violation).

Explain why your rule encodes "good" design.
  
Part 2:  
 
Complete the body of this function to check a Dicto rule
against the information on the M3 model (which will come
from the pacman project). 

A simple way to get started is to pattern match on variants
of the rules, like so:

switch (rule) {
  case (Rule)`<Entity e1> cannot depend <Entity e2>`: ...
  case (Rule)`<Entity e1> must invoke <Entity e2>`: ...
  ....
}

Implement each specific check for each case in a separate function.
If there's a violation, produce an error in the `msgs` set.  
Later on you can factor out commonality between rules if needed.

The messages you produce will be automatically marked in the Java
file editors of Eclipse (see Plugin.rsc for how it works).

Tip:
- for info on M3 see series2/A1a_StatCov.rsc.

Questions
- how would you test your evaluator of Dicto rules? (sketch a design)

	After a careful observation of the files, we noticed that the jpacman
	is using MVC architecture (Model-View-Control). Model is represented by
	the classes “npc, level, game, board”, in model  we can see the logic of
	the game. Controller handles the user request, in jPacman , “ui” class use
	keylistener so we end up that it is the controller of the project. Finally,
	“sprite” is the View of the project because it has all the graphics. 
	Depend on the MVC architecture we define the follow rules: 
	1)	Model cannot depend on View 
		a.	npc cannot depend sprite
		b.	level cannot depend sprite
		c.	game cannot depend sprite
	2)	Model cannot depend on Controller 
		a.	npc cannot depend ui
		b.	level cannot depend ui
		c.	game cannot depend ui
	3)	Controller must depend on View 
		a.	ui must depend sprite
	4)	Controller must depend on Model
		a.	ui must depend npc
		b.	ui must depend level
		c.	ui must depend game
		d.	ui must depend board
	5)	View cannot depend on Model 
		a.	sprite cannot depend npc
		b.	sprite cannot depend level
		c.	sprite cannot depend game


- come up with 3 rule types that are not currently supported by this version
  of Dicto (and explain why you'd need them). 
  
 	A system needs updates all the time, so we have a lot of versions. We need
 	the ability to mark up versions of components and check them for compatibility
 	with old versions. Moreover, when a component changes its visibility, we need to
 	have a rule to check if other components affected by this change. Also, to enable
 	components to interact, we need a rule to check the dependencies between interfaces.
    
  
  |project://sqat-analysis/src/sqat/series2/checkArch.dicto|
  
  run:
  import sqat::series2::A2_CheckArch;
  import sqat::series2::Dicto;
  import ParseTree;
  import lang::java::jdt::m3::Core;
  M3 m3=createM3FromEclipseProject(|project://jpacman-framework|);
  pt = parse(#start[Dicto], |project://sqat-analysis/src/sqat/series2/checkArch.dicto|);
  eval(pt, m3);
  
  
*/



set[Message] checkNotDependOn(rel [loc src,loc name] dependencies, set[loc] modelClasses, Entity e1, Entity e2){
	set[Message] msgs = {};
 	count=0;
	for (i<-modelClasses){
		loc x=i.parent;
		str k=x.file;
		str c= "<e1>";
		if (k==c){
			for (index<-dependencies){
				if (contains("<index<src>>","<k>") && contains("<index<name>>","<e2>")){
					count+=1;
					msgs+= error("<e1> cannot depend <e2>",index<src>);
					//println("<index<src>>,  <k>,  <index<name>>,  <e2>");
				}
			}			
		}
	}
	return msgs;
}


set[Message] checkControllerDepend (rel [loc src,loc name] dependencies, set[loc] modelClasses, Entity e1, Entity e2){
	set[Message] msgs = {};
 	count=0;
 	loc folder;
	for (i<-modelClasses){
		loc x=i.parent;
		str k=x.file;
		str c= "<e1>";
		if (k==c){
		folder=i;
			for (index<-dependencies){
				if (contains("<index<src>>","<k>") && contains("<index<name>>","<e2>")){
					count+=1;
					//println("<index<src>>,  <k>,  <index<name>>,  <e2>");				
				}
			}			
		}
	}
	if (count==0){
		msgs+= error("<e1> must depend <e2>",folder);
	}
	return msgs;
}


set[Message] eval(start[Dicto] dicto, M3 m3) = eval(dicto.top, m3);

set[Message] eval((Dicto)`<Rule* rules>`, M3 m3) 
  = ( {} | it + eval(r, m3) | r <- rules );
  
M3 jpacmanM3() = createM3FromEclipseProject(|project://jpacman-framework|);
  
set[Message] eval(Rule rule, M3 m3) {
  set[Message] msgs = {};
  	rel[loc src,loc name] dependencies={};
 	modelClasses=classes(m3);
 	mu=m3.uses;
 		for (classes<-mu){
 			if (classes<name>.scheme=="java+class"){
				dependencies+=classes;
 			}
 		}
  
  switch (rule) {
  case (Rule)`<Entity e1> cannot depend <Entity e2>`: msgs+=checkNotDependOn(dependencies,modelClasses,e1,e2);
  case (Rule)`<Entity e1> must depend <Entity e2>`: msgs+=checkControllerDepend(dependencies,modelClasses,e1,e2);
}
  
  return msgs;
}


