#!/bin/bash
# A tiny automation script that generates tests for a 
# given input and outputs results on file and stdout.
# TODO: in order to rename results incrementally as KLEE
# does, we need to get last KLEE build number. Smth like

#export PATH=/media/w7/Projects/klee-cde-package/bin:$PATH;
#export PATH=/media/w7/Projects/blast-2.5_linux-bin-x86:$PATH;
#export PATH=/media/w7/Projects/cvc-linux-1.0a/bin:$PATH;
# need to log an aproximation profiling

#if [[ ${file: -4} ~= /regex/ ]]
prefix="out";
results="$prefix/results.txt";
cvc="$prefix/assertions.txt";


if [ $# -eq 0 ]; then
  echo -e "\n You have not specified any source files
 That is $0 <file1.c> <file2.c>..\n";
else
  for file in $*; do
    if [[ ! -f "$file" ]]; then
      echo -e "File $file is not in `pwd` \n";
      exit 1;
    fi
  done
fi

if [[ -f "$results" ]]; then
  rm "$results";
fi
touch "$results";

for file in $*; do
  echo -e "\n[$file][Compiling to LLVM bitcode]\n";
  llvm-gcc.cde --emit-llvm -c -g $file;
  echo -e "[$file][Running KLEE]\n";
  START=$(date +%s)
  klee.cde -write-cvcs `echo $file | sed "s/c$/o/"`;
  END=$(date +%s)
# use grep to get the results
  echo -e "\n[$file][Generated x paths in $(( $END - $START )) seconds]\n";
  echo -e "\n[$file][Outputting results]\n";
  echo -e "\n[$file][Converting klee results from bin to ascii]\n" | tee -a "$results";
  ktest-tool.cde klee-last/test*.ktest  >> "$results"; #| tee -a
  echo -e "\n[$file][Converting cvc results to branch statements]\n" | tee -a "$results";
  cd pathconditions/
  java CreateAssertion ../klee-last/test*.cvc >> "../$cvc"; #| tee -a "$cvc";
  cd ..
done

# Output when tests are done
if [ -f `which notify-send` ]; then 
  notify-send "Project \"Glucose\"" "Completed Test Case Generation" -i /usr/share/pixmaps/gnome-color-browser.png -t 5000
fi
