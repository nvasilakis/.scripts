#!/bin/bash
# A script that automates the generation and killing 
# process of mutants for the purposes of testing 

if [ $# -eq 0 ]; then
  echo -e "\n Please supply the class name e.g.,
  for <GPXsomething.java> run $0 <GPXsomething> \n";
else
#  if [[ $1 -eq "-all" ]]; then
#    for file in ../eclipse/test/Mutant*Test.java; do
#      
#    done
#  fi
  echo "Updating project Structure"
  cp ../eclipse/src/*.java ./src/;
  cp ../eclipse/bin/GPX*.class ./classes/;
  rm ./classes/*Test.class;
  cp ../eclipse/bin/Mutant$1Test.class ./testset/;
  echo "Generating Mutants"
  echo -e `echo $CLASSPATH | grep mujava`\n >> ~/Desktop/log.txt 
  export CLASSPATH=$CLASSPATH:/usr/lib64/jvm/java-1.6.0-sun-1.6.0/lib/tools.jar:/home1/n/nvas/Programs/lib/mujava.jar:/home1/n/nvas/Programs/lib/openjava2005.jar;
  export CLASSPATH=$CLASSPATH:/home1/n/nvas/Downloads/GPXstats/mujava/classes;
  export CLASSPATH=$CLASSPATH:/home1/n/nvas/Downloads/GPXstats/mujava/src;
  export CLASSPATH=$CLASSPATH:/home1/n/nvas/Downloads/GPXstats/mujava/testset;
  echo -e `echo $CLASSPATH | grep mujava`\n >> ~/Desktop/log.txt
  java mujava.gui.GenMutantsMain
  echo "Running Mutants"
  CLASSPATH=$(echo $CLASSPATH | sed -e 's;:\?/home1/n/nvas/Downloads/GPXstats/mujava/classes;;')
  echo -e `echo $CLASSPATH | grep mujava`\n >> ~/Desktop/log.txt
  java mujava.gui.RunTestMain
fi
