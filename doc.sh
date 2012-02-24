#!/bin/bash - 

##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that  alters the entire javadoc set of  files, removing menus
# etc, making it easy to convert to pdf format and eventually converting
# to a pdf format. Note: the script needs to be run from the top-most
# dir of the project structure (just above src).
#
# Usage: ./doc.sh
#
# required arguments: None
##

# Create javadoc in html format
ant javadoc
cd javadoc/

# Create the array of javadoc files to be included, in the form of
# backEnd/model/Scenario.html
# backEnd/managers/SectionManager.html

array= "$(%find -name '*.html')"

# Tide-up every javadoc file -- remote menues etc
for i in $array; do 
  echo "working on $i";
  sed -i -e '/START.*TOP NAVBAR/,/END.*TOP NAVBAR/d' -e  '/START.*BOTTOM NAVBAR/,/END.*BOTTOM NAVBAR/d' $i;
done

output="documentation.pdf"

if [[ "$#" != "0" ]]; then
  echo "renaming output"
  output=$1
fi

# convert to pdf via htmldoc -- please do change parameters only if you know what you are doing
# parameters customized for EduTubePlus Learning Scenario Tool Documentation pdf
echo "converting to pdf.."
htmldoc -t pdf13 -f $output --continuous --no-title --linkstyle underline --size Universal --left 1.00in --right 0.50in --top 0.50in --bottom 0.50in --header ... --header1 ... --footer ... --nup 1 --tocheader .t. --tocfooter ..i --portrait --color --no-pscommands --no-xrxcomments --compression=9 --jpeg=0 --fontsize 11.0 --fontspacing 1.2 --headingfont Helvetica --bodyfont Times --headfootsize 11.0 --headfootfont Helvetica --charset iso-8859-1 --links --embedfonts --pagemode document --pagelayout single --firstpage p1 --pageeffect none --pageduration 10 --effectduration 1.0 --no-encryption --permissions all  --owner-password ""  --user-password "" --browserwidth 680 --no-strict --no-overflow $array

