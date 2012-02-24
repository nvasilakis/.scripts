#!/bin/bash

##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A tiny  automation script that generates  tests for a given  input and
# outputs results on file and stdout.  The script make uses of KLEE, for
# brute force test generation in order  to cover all possible paths, and
# BLAST for testing whether certain paths are indeed reachable or not --
# that is, there  exists input that can lead the  program to that state.
# The script also pushes to the system notification daemon when done.
#
# Usage: generateTests [-a|-c] <file.c>
#
# Required arguments: 
# <file.c>  the source  file treating  variables as  independent. Please
#           make  sure  there  is  a  twin  <file>_dependent.c  treating
#           variables as dependent
#           
# Optional arguments:
# -a        Add KLEE, BLAST and cvc theorem prover to path
# -r        Remove KLEE, BLAST and cvc theorem prover from path
#
# TODO:  *  in order  to rename results  incrementally as KLEE  does, we
#           need to get last KLEE build number. [regex]
#        *  create _dependent.c automatically
#        *  implement better profiling
#        *  -max-forks=1000 for KLEE
##

##
# Function  configure_path configures  the $PATH  environmental variable
# for  the  scripts  to  run  (regarding KLEE,  BLAST  and  cvc  theorem
# prover).
#
#  Note: If the "generateTests.sh" script is sourced with -a or -d flags
# then it only alters the path  (without generating tests) even for when
# the script exists  (This is particularly if someone  wants to generate
# selected tests without the use of this script
#
# input: "add" | "remove" depending on the the path modification
##
function configure_path {
  klee_path="/media/w7/Projects/klee-cde-package/bin";
  blast_path="/media/w7/Projects/blast-2.5_linux-bin-x86";
  cvc_path="/media/w7/Projects/cvc-linux-1.0a";
  # String comparison
  if [[ $1 = "add" ]]; then
    if [ -d $klee_path  ]; then
      export PATH=$klee_path:$PATH;
    else
      echo "[ERROR] KLEE was not found"
    fi
    # Adding path for BLAST
    if [ -d $blast_path  ]; then
      export PATH=$blast_path:$PATH;
    else
      echo "[ERROR] BLAST was not found"
    fi
    # Adding path for cvc theorem
    if [ -d  $cvc_path ]; then
      export PATH=$cvc_path:$PATH;
    else
      echo "[ERROR] CVC Theorem Proover was not found"
    fi
  # Removing paths to klee, blast and cvc
  elif [[ $1 = "remove" ]]; then
    PATH=$(echo $PATH | sed -e "s;:\?$klee_path;;")
    PATH=$(echo $PATH | sed -e "s;:\?$blast_path;;")
    PATH=$(echo $PATH | sed -e "s;:\?$cvc_path;;")
    #In case we deleted something from the beginning
    PATH=$(echo $PATH | sed -e "s;^:;;")
  fi
  echo -e "[Env] \$PATH=$PATH\n";
}

#if [[ ${file: -4} ~= /regex/ ]]
prefix="out";
results="$prefix/results.txt";
cvc="$prefix/assertions.txt";

# Processing input flags and non-existent files
if [ $# -eq 0 ]; then
  echo -e "\n You have not specified any source files
 That is $0 <file1.c> <file2.c>..\n";
else
  for file in $*; do
    #if [ `"$file" | grep -c '^\-\(s|setup\)' ` -eq 0 ]; then
    if [[ ! -f "$file" ]]; then
      # Instead of boolean we compare with the number of occurences
      if [ `echo "$file" | grep -c "^\-\(a\|add\)"` -eq 1 ]; then
        configure_path 'add';
        exit 0;
      elif [ `echo "$file" | grep -c "^\-\(r\|remove\)"` -eq 1 ]; then
        configure_path 'remove';
        exit 0;
      fi
      echo -e "File $file is not in `pwd` \n";
      exit 1;
    fi
  done
fi
# Always adding the path before starting computations
configure_path 'add';
echo -e "[Env] Recreating $results and $cvc folders\n";
# Recreating results report
if [[ -f "$results" ]]; then
  rm "$results" "$cvc";
fi
touch "$results" "$cvc";

# Default input would be a number of files
for file in $*; do
  echo -e "\n[$file][Compiling to LLVM bitcode]\n";
  llvm-gcc.cde --emit-llvm -c -g $file;
  echo -e "[$file][Running KLEE]\n";
  # Recording time for KLEE
  START=$(date +%s)
  klee.cde -write-cvcs `echo $file | sed "s/c$/o/"`;
  END=$(date +%s)
  # use grep to get the results
  echo -e "\n[$file][Generated in $(( $END - $START )) seconds]\n";
  echo -e "\n[$file][Outputting results]\n";
  echo -e "\n[$file][Converting klee results from bin to ascii]\n" | tee -a "$results";
  ktest-tool.cde klee-last/test*.ktest  >> "$results"; #| tee -a
  echo -e "\n[$file][Converting cvc results to branch statements]\n" | tee -a "$results";
  # Running the java assertion classes in order to interpret KLEE ouput
  cd pathconditions/
  java CreateAssertion ../klee-last/test*.cvc >> "../$cvc"; #| tee -a "$cvc";
  cd ..
  # TODO Generate a dependent file automatically
  # Parsing input (filename) in order to locate the dependent version
  dependent=$(echo $file | sed -e "s/\(.*\)\.c/\1_dependent\.c/")
  echo -e "\n[$file][Running BLAST on $dependent]\n" | tee -a "$results";
  # Read modified output interpretation and run BLAST on each assertion (every 3 lines)
  sed -e "/^$/ d" -e "/====/ d" $cvc | while read -r line; do
    assertion=$line && read -r line;
    # Insert assertion in the dependent version
    sed " /#BLAST#/ a\  if $line \{ \n    goto ERROR;\n    ERROR: assert(0);\n  \}" $dependent > temp.c
    echo -e "$line" >> $results
    output=`pblast.opt temp.c | grep -oh '\(\w*safe\w*\|^Ack!\)'`;
    # Parse output for the results and transliterate 
    processed=`echo $output | sed -e "s/^unsafe unsafe/reachable/" -e "s/^safe safe/unreachable/" -e "s/Ack!/unknown/"`
    echo $processed
    echo $processed >> $results
    echo -e "$assertion \n" >> $results
    pblast.opt temp.c | grep -oh "\w*safe\w*" >> $results;
  done
done

#Notify us when everything is done
if [ -f `which notify-send` ]; then 
  notify-send "Project \"Glucose\"" "Completed Test Case Generation" -i /usr/share/pixmaps/gnome-color-browser.png -t 5000
  # maybe send me an email if time was more than 30'?
fi
