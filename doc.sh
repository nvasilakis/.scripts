#!/bin/bash - 
#===============================================================================
#
#          FILE:  doc.sh
# 
#         USAGE:  ./doc.sh 
# 
#   DESCRIPTION:  A script that alters the entire javadoc set of files, removing
#                 menus etc, making it easy to convert to pdf format.
# 
#  REQUIREMENTS:  Run the script from the top-most dir of the project structure
#         NOTES:  ---
#        AUTHOR: Nikos Vasilakis
#       COMPANY: RACTI
#       CREATED: 05/20/2011 03:09:29 PM EEST
#      REVISION: 0.8
#===============================================================================

# Create javadoc in html format
ant javadoc
cd javadoc/

# Create the array of javadoc files to be included
array='
backEnd/managers/AbstractManager.html
backEnd/managers/ScenarioManager.html
backEnd/managers/SectionManager.html
backEnd/managers/SectionScenarioManager.html
backEnd/managers/SectionTemplateManager.html
backEnd/managers/SectionTypeManager.html
backEnd/managers/TemplateManager.html
backEnd/managers/TranslationManager.html
backEnd/managers/WordManager.html
backEnd/filter/CharsetFilter.html
backEnd/model/Scenario.html
backEnd/model/Section.html
backEnd/model/SectionScenario.html
backEnd/model/SectionTemplate.html
backEnd/model/SectionType.html
backEnd/model/Template.html
backEnd/model/Translation.html
backEnd/model/Word.html
backEnd/util/HibernateUtil.html'

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

