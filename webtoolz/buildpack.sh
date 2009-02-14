#!/bin/bash
#
# Title: Desaturate CSS files
# Created By: Tyler Mulligan of www.detrition.net
#
# Usage: place script in the same folder as your stylesheet and ./desaturate style.css
#

# This Packages this experiment
build_package() {
	find $(pwd) -type f -print | egrep -v 'buildpack\.sh|webtoolz-pack_' | sed "s#$(pwd)/##" > tarlist.txt
	xargs tar cvf webtoolz-pack_$( date +%m%d%y ).tar < tarlist.txt
	rm tarlist.txt
} # End pack_nst

build_package
