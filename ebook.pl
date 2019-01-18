#!/usr/bin/perl

####### CONVERT LaTeX FILE IN EBOOK
# dependences: latexml, calibre, all requested to compile LaTeX file;
# 
# To install them:
# $ sudo apt update && sudo apt install latexml calibre
#
# Usage:
# $ ./ebook <./path/file1.tex> <./path/file2.tex> <./path/file3.tex> ...
# this script will convert each file directly in its subdirectory, the
# output file has the same name of the original file and it is placed
# in the same (sub)directory.
#
# Format supported: all by calibre.
# Just (un)comment the next lines to change output format.
# Feel free to add more format.
#
$FORMAT = "azw3";   # (amazon kindle)
#$FORMAT = "epub";
#$FORMAT = "mobi";
#
#
# By hand:
# This script will no prompt any output, so if something goes wrong
# you cannot say where the error is. So, you have to compile the ebook
# by hand, those are the commands:
# $ latexml --dest=output.xml input.tex
# $ latexmlpost -dest=output.html input.xml  
# $ ebook-convert input.html output.(epub|mobi|azw3) --language (it|en)
#
# If it is not enought, I do not care: just learn to use google and
# correct it by your own.
#######


sub find_language {
    # LaTeX uses english by default
    my $lang = "en";
    open(file, "<".shift);
    while(<file>) {
	# REGEX REGEX REGEX
	if ($_ =~ /\\usepackage\[\w+\]\{babel\}/) {
	    # REEEEGEEEXXXXX
	    ($lang) = $& =~ /\[(\w{2})\w*\]/;
	    # I hope the first two letters are the right language
	    # (italian -> it)
	    last;
	}
    }
    # Close the file, I'm such a good person...
    close(file);
    return $lang;
}

sub convert {
    my $file = shift;
    unless(-e $file) {
	# oh no, you typed it wrong
	print "$file not found \n";
	return 0;
    }
    # lets start :D
    print "Converting $file \n";
    print "  - releaving language: ";
    my $lang = find_language($file); # a very complicated algorithm...
    print "$lang \n";
    (my $path, $file, my $filename) = $file =~
	# IT'S A FUCKING REGEX *.*
	/^((?:.+)*\/)?(([\w\s]+)\.tex)$/;
    # DO NOT TOUCH, it just works, no output will be show
    print "  - .tex -> .xml ";
    system("latexml --dest=\"$path$filename.xml\" \"$path$file\" " .
	   "2> /dev/null");
    print "-> .html ";
    system("latexmlpost -dest=\"$path$filename.html\" " .
    	   "\"$path$filename.xml\" " .
	   "2> /dev/null");
    print "-> .$FORMAT \n";
    system("ebook-convert \"$path$filename.html\" " .
    	   "\"$path$filename.$FORMAT\" --language $lang " .
	   "> /dev/null 2> /dev/null");
    print "  - cleaning $path \n";
    # this line just remove files used in the building process
    system("rm -f \"$path$filename.xml\" " .
	   "\"$path$filename.html\" " .
	   "\"$path"."LaTeXML.css\" " .
	   "\"$path"."ltx-article.css\"");
    if(-e "$path$filename.$FORMAT") { # I hope this is the case
	print "  - done \n";
	return 1;
    } else {  # oh no, something went wrong! I am terrible sorry, but
	      # I wrote just a stupid script... something is wrong in
	      # latexml or calibre... try compiling the ebook by hand
	print "  !! something went wrong \n";
	return 0;
    }
}

convert $_ foreach(@ARGV);
