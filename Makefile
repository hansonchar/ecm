## This file is part of the book                 ##
##                                               ##
##   Discrete Mathematics: An Open Introduction  ##
##                                               ##
## Copyright (C) 2015-2018  Oscar Levin          ##
## See the file COPYING for copying conditions.  ##

## Based on the corresponding file from          ##
##  Abstract Algebra: Theory and Applications    ##
##  by Tom Judson                                ##

#######################
# DO NOT EDIT THIS FILE
#######################

#   1) Do make a copy of Makefile.paths.original
#      as Makefile.paths
#   2) Edit Makefile.paths to provide full paths to the root folders
#      of your local clones of the project repository and the mathbook
#      repository as described below.
#   3) The files Makefile and Makefile.paths.original
#      are managed by git revision control and any edits you make to
#      these will conflict. You should only be editing Makefile.paths.

##############
# Introduction
##############

# This is not a "true" makefile, since it does not
# operate on dependencies.  It is more of a shell
# script, sharing common configurations

# This is mostly offered as an example of one approach
# to managing a project with multiple output formats. and
# is not claimed to be "best practice"

######################
# System Prerequisites
######################

#   install         (system tool to make directories)
#   xsltproc        (xml/xsl text processor)
#   tar             (to package SageMathCloud worksheets for upload)
#   xmllint         (only to check source against DTD)
#   <helpers>       (PDF viewer, web browser, pager, Sage executable, etc)

#####
# Use
#####

#	A) Set default directory to be the location of this file
#	B) At command line:  make solutions  (and employ targets)



# The included file contains customized versions
# of locations of the principal components of this
# project and names of various helper executables
include Makefile.paths

# These paths are subdirectories of
# the Mathbook XML distribution
# MBUSR is where extension files get copied
# so relative paths work properly
PTXXSL = $(PTX)/xsl
PTXSCRIPT = $(PTX)/script
PTXUSR = $(PTX)/user
PTXRELAXNG = $(PTX)/schema

# These are source and custom XSL subdirectories
# for the two DMOI repositories
SRC = $(DMOI)/ptx
XSL = $(DMOI)/xsl

# These paths are subdirectories of
# a scratch directory
HTMLOUT    = $(SCRATCH)/html
PDFOUT     = $(SCRATCH)/latex
SMCOUT     = $(SCRATCH)/aata-smc
DOCTEST    = $(SCRATCH)/doctest
EPUBOUT    = $(SCRATCH)/epub
SAGENBOUT  = $(SCRATCH)/sagenb
JUPYTEROUT = $(SCRATCH)/jupyter


# Following regularly presumes  xml:id="aata" on
# the <book> element, so xsltproc creates  aata.tex

###############
# Preliminaries
###############

# Diagrams
#   invoke mbx script to manufacture diagrams
#   tikz as SVG for HTML
#   sageplot as PDF for LaTeX, SVG for HTML
#   these outputs are in source repo now, and
#   are typically just copied out
#   this should be run if diagram source changes
#   NB: targets below copy versions out of repo and clobber these
diagrams:
	install -d $(HTMLOUT)/images
	-rm $(HTMLOUT)/images/*
	$(MBSCRIPT)/mbx -v -c latex-image -f svg -d $(HTMLOUT)/images $(SRC)/aata.xml
	$(MBSCRIPT)/mbx -v -c sageplot    -f pdf -d $(HTMLOUT)/images $(SRC)/aata.xml
	$(MBSCRIPT)/mbx -v -c sageplot    -f svg -d $(HTMLOUT)/images $(SRC)/aata.xml


##########
# Products
##########

# HTML version
#   Copies in image files from source directory
#   Move to server: generated *.html and
#   entire directories - /images and /knowl
html:
	install -d $(HTMLOUT) $(MBUSR)
	cp -a $(SRC)/images $(HTMLOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-html.xsl $(MBUSR)
	cd $(HTMLOUT); \
	xsltproc --xinclude $(MBUSR)/aata-html.xsl $(SRC)/aata.xml

viewhtml:
	$(HTMLVIEWER) $(HTMLOUT)/aata.html &

# Full PDF version with Sage
#   copies in all image files, which is overkill (SVG's)
#   produces  aata-sage.tex  in scratch directory
#   which becomes PDF, along with index entries
#   Includes *all* material, and is fully electronic
#   This is the DMOI/Sage downloadable Annual Edition
sage:
	# delete old  xsltproc  output
	# dash prevents error if not found
	-rm $(PDFOUT)/aata.tex
	install -d $(PDFOUT) $(MBUSR)
	cp -a $(SRC)/images $(PDFOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-latex.xsl $(XSL)/aata-sage.xsl $(MBUSR)
	cd $(PDFOUT); \
	xsltproc --xinclude $(MBUSR)/aata-sage.xsl $(SRC)/aata.xml; \
	$(ENGINE) aata.tex; $(ENGINE) aata.tex; \
	mv aata.pdf aata-sage.pdf

# View PDF from correct directory
viewsage:
	$(PDFVIEWER) $(PDFOUT)/aata-sage.pdf &

# Electronic PDF version
#   copies in all image files, which is overkill (SVG's)
#   produces  aata-electronic.tex  in scratch directory
#   which becomes PDF, along with index entries
#   Similar to "print" but with links, etc.
#   No Sage material
#   This is default downloadable Annual Edition
#   ie, aata-YYYYMMDD.pdf in repository download section
electronic:
	# delete old  xsltproc  output
	# dash prevents error if not found
	-rm $(PDFOUT)/aata.tex
	install -d $(PDFOUT) $(MBUSR)
	cp -a $(SRC)/images $(PDFOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-latex.xsl $(XSL)/aata-electronic.xsl $(MBUSR)
	cd $(PDFOUT); \
	xsltproc --xinclude $(MBUSR)/aata-electronic.xsl $(SRC)/aata.xml; \
	$(ENGINE) aata.tex; $(ENGINE) aata.tex; \
	mv aata.pdf aata-electronic.pdf

# View PDF from correct directory
viewelectronic:
	$(PDFVIEWER) $(PDFOUT)/aata-electronic.pdf &

# Print PDF version
#   A print version for print-on-demand
#   This will be source for the Annual Edition,
#     as sent to Orthogonal Publishing for modification
#   Black on white, no live URLs, etc
#   This is the "printable" downloadable Annual Edition
print:
	# delete old  xsltproc  output
	# dash prevents error if not found
	-rm $(PDFOUT)/aata.tex
	install -d $(PDFOUT) $(MBUSR)
	cp -a $(SRC)/images $(PDFOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-latex.xsl $(XSL)/aata-print.xsl $(MBUSR)
	cd $(PDFOUT); \
	xsltproc --xinclude $(MBUSR)/aata-print.xsl $(SRC)/aata.xml; \
	$(ENGINE) aata.tex; $(ENGINE) aata.tex; \
	mv aata.pdf aata-print.pdf

# View PDF from correct directory
viewprint:
	$(PDFVIEWER) $(PDFOUT)/aata-print.pdf &

# Author's Draft
#   Like electronic PDF version, but for:
#   No index created, since showidx is used
#   Various markup for author's use, todo's etc
draft:
	# delete old  xsltproc  output
	# dash prevents error if not found
	-rm $(PDFOUT)/aata.tex
	install -d $(PDFOUT) $(MBUSR)
	cp -a $(SRC)/images $(PDFOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-latex.xsl $(XSL)/aata-electronic.xsl $(MBUSR)
	cd $(PDFOUT); \
	xsltproc --xinclude --stringparam author-tools 'yes' \
	--stringparam latex.draft 'yes' $(MBUSR)/aata-electronic.xsl $(SRC)/aata.xml; \
	$(ENGINE) aata.tex; $(ENGINE) aata.tex; \
	mv aata.pdf aata-draft.pdf

viewdraft:
	$(PDFVIEWER) $(PDFOUT)/aata-draft.pdf &


######
# Sage
######

# DMOI has extensive support for Sage
# These targets are all related to that

# Doctest
#   All Sage material, but not solutions to exercises
#   Prepare location, remove *.py from previous runs
#   XSL dumps into current directory, Sage processes whole directory
#   chunk level 2 gives sections (commentaries, exercises)
doctest:
	-rm $(DOCTEST)/*.py; \
	install -d $(DOCTEST)
	cd $(DOCTEST); \
	xsltproc --xinclude --stringparam chunk.level 2 $(MBXSL)/mathbook-sage-doctest.xsl $(SRC)/aata.xml; \
	$(SAGE) -tp 0 .

# SageMathCloud worksheets
#   can upload, extract tarball
#   that has "aata-smc" as root directory
#     $ tar -xvf aata-smc.tgz
smc:
	install -d $(SMCOUT) $(MBUSR)
	cp -a $(SRC)/images $(SMCOUT)
	cp -a $(MB)/css/mathbook-content.css $(MB)/css/mathbook-add-on.css $(SMCOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-smc.xsl $(MBUSR)
	cd $(SMCOUT); \
	xsltproc --xinclude $(MBUSR)/aata-smc.xsl $(SRC)/aata.xml
	# wrap up into a tarball in SCRATCH
	# NB: subdir must match with SMCOUT
	tar -c -z -f $(SCRATCH)/aata-smc.tgz -C $(SCRATCH) aata-smc

###########
# Utilities
###########

## Clean solutions for student version ##

cleansols:
	install -d $(SCRATCH)
	install -d $(SCRATCH)/ptx-clean
	install -d $(SCRATCH)/ptx-clean/exercises
	# -rm $(SCRATCH)/ptx-clean/*.ptx
	# # -rm $(SCRATCH)/ptx-clean/exercises/*.ptx
	# for f in ptx/*.ptx; do \
	# 	xsltproc -o ptx-clean/$${f##*/} xsl/clean-solutions.xsl $$f; \
	# done
	$(foreach var,$(wildcard ptx/*.ptx), \
		xsltproc -o ptx-clean/$(notdir $(var)) xsl/clean-solutions.xsl $(var);)
	$(foreach var,$(wildcard ptx/exercises/*.ptx), \
		xsltproc -o ptx-clean/exercises/$(notdir $(var)) xsl/clean-solutions.xsl $(var);)
	# xsltproc -o $(SCRATCH)/ptx-clean/ xsl/clean-solutions.xsl $(widcard $(DMOI)/ptx/*.ptx)
	# xsltproc xsl/clean-solutions.xsl $(widcard $(DMOI)/ptx/*.ptx)






## THESE NEED WORK ##

# Check document source against the DTD
#   Leaves "dtderrors.txt" in SCRATCH
#   can then grep on, eg
#     "element XXX:"
#     "does not follow"
#     "Element XXXX content does not follow"
#     "No declaration for"
#   Automatically invokes the "less" pager, could configure as $(PAGER)
check:
	install -d $(SCRATCH)
	-rm $(SCRATCH)/dtderrors.*
	-xmllint --xinclude --noout --dtdvalid $(MBDTD)/mathbook.dtd $(SRC)/aata.xml 2> $(SCRATCH)/dtderrors.txt
	less $(SCRATCH)/dtderrors.txt

viewcheck:
	less $(SCRATCH)/dtderrors.txt

##############
# Experimental
##############

# These are in-progress and/or totally broken

# Jupyter Notebooks - experimental
jupyter:
	install -d $(JUPYTEROUT) $(MBUSR)
	cp -a $(SRC)/images $(JUPYTEROUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-jupyter.xsl $(MBUSR)
	cd $(JUPYTEROUT); \
	xsltproc --xinclude $(MBUSR)/aata-jupyter.xsl $(SRC)/aata.xml


# Sage Notebooks
#   Need to  make diagrams first (not a true makefile)
#   First, all content
#   Copy all the pieces into place relatice to $SCRATCH
#   Drop result in $SAGENBOUT
sagenb:
	install -d $(HTMLOUT)
	cp -a $(SRC)/*.xml $(SRC)/images $(SRC)/exercises $(SRC)/sage $(SCRATCH)
	cp -a $(HTMLOUT)/images $(SCRATCH)
	$(MBSCRIPT)/mbx -v -c all -f sagenb -o $(SAGENBOUT)/aata.zip $(SCRATCH)/aata.xml

# This makes a zip file of a version for use at AIM Books
# Clean out directories first by hand
# Date and upload
# HTML version
#   Copies in image files from source directory
aimhtml:
	install -d $(HTMLOUT) $(MBUSR)
	cp -a $(SRC)/images $(HTMLOUT)
	cp $(XSL)/aata-common.xsl $(XSL)/aata-html.xsl $(MBUSR)
	sed -i -e 's/002637997310187229905:qj2oy0jlpyu/008832104071767086392:pxbnbrlbfwa/' $(SRC)/bookinfo.xml
	cd $(HTMLOUT); \
	xsltproc --xinclude --stringparam html.annotation hypothesis $(MBUSR)/aata-html.xsl $(SRC)/aata.xml
	sed -i -e 's/008832104071767086392:pxbnbrlbfwa/002637997310187229905:qj2oy0jlpyu/' $(SRC)/bookinfo.xml
	mv $(SCRATCH)/html $(SCRATCH)/aata-html
	cd $(SCRATCH); \
	zip -r $(SCRATCH)/aata-html-2018-datehere.zip aata-html/


# EPUB 3.0 assembly
#	TODO: fix retrieval of CSS (via wget?)
epub:
	rm -rf $(EPUBOUT)
	install -d $(EPUBOUT) $(EPUBOUT)/EPUB/css $(EPUBOUT)/EPUB/xhtml
	cd $(EPUBOUT); \
	xsltproc --xinclude  $(MBXSL)/mathbook-epub.xsl $(SRC)/aata.xml
	rm -rf $(EPUBOUT)/knowl
	cp ~/mathbook/local/epub-trial/mathbook-content.css $(EPUBOUT)/EPUB/css/
	cp -a $(SRC)/images $(EPUBOUT)/EPUB/xhtml
	cp -a $(EPUBOUT)/EPUB/xhtml/images/cover_aata_2014.png $(EPUBOUT)/EPUB/xhtml/images/cover.png
	#
	cp -a /media/rob/disk/mathjax-out/*.html $(EPUBOUT)/EPUB/xhtml
	#
	cd $(EPUBOUT); \
	zip -0Xq  aata-mathml.epub mimetype; zip -Xr9Dq aata-mathml.epub *
