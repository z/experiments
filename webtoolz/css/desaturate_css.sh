#!/bin/bash
#
# Title: Desaturate CSS files
# Created By: Tyler Mulligan of www.detrition.net
#
# Usage: place script in the same folder as your stylesheet and ./desaturate style.css
#

function convert_all_css() {
	echo $1
	case $1 in
	  d) effect="css_desaturate";;
	  r) effect="css_random";;
	  *) effect="css_desaturate";;
	esac
	for stylesheet in $(ls *.css |grep -v "_\(desaturated\|random\)"); do
		$effect $stylesheet
	done
}

function css_desaturate() {
	if [[ "$1" == "" ]]; then
		old_stylesheet="default.css"
	else
		old_stylesheet=$1
	fi
	new_stylesheet=$(echo ${old_stylesheet} | sed 's/\(.*\)\(\.css\)$/\1_desaturated\2/i')
	rm $new_stylesheet
	cp $old_stylesheet $new_stylesheet
	echo -e "\n -= Converting Stylesheet: $old_stylesheet to $new_stylesheet =-\n"
	for line in $(grep -i "\#\([0-9a-f]\{3\}\|[0-9a-f]\{6\}\)" ${old_stylesheet}); do
		# grab the color
		color=$(echo $line | grep -i "\#\([0-9a-f]\{3\}\|[0-9a-f]\{6\}\)" | sed 's/.*\#\([0-9a-f]\{6\}\|[0-9a-f]\{3\}\).*/\#\1/gi')
		if [[ "$color" != "" ]]; then
			# replace the color in the stylesheet
			desaturated=$(hex_desaturate $color)
			echo "  -> $color to $desaturated"
			sed -i "s/${color}\(\s\|\;\)/${desaturated}\1/g" $new_stylesheet
		fi
	done
	echo -e "\n -= Converting Images =-\n"
	for line in $(grep -i "url(.*)" $old_stylesheet | sed "s/.*('\(.*\)').*/\1/gi"); do
		old_image=$line
		# Images
		echo "  -> desaturating: $line"
		image_desaturate $old_image
		# edit stylesheet
		new_image=$(echo ${line} | sed 's/\(.*\)\(\.[a-z]\{3,4\}\)$/\1_desaturated\2/i')
		echo "  -> updating stylesheet to: $new_image"
		sed -i "s#${old_image}#${new_image}#g" $new_stylesheet
	done
	echo -e "\n -= COMPLETE! =-\n"
}

# random colors
function css_random() {
	if [[ "$1" == "" ]]; then
		old_stylesheet="lolwut.css"
	else
		old_stylesheet=$1
	fi
	new_stylesheet=$(echo ${old_stylesheet} | sed 's/\(.*\)\(\.css\)$/\1_random\2/i')
	rm $new_stylesheet
	cp $old_stylesheet $new_stylesheet
	echo -e "\n -= Converting Stylesheet: $old_stylesheet to $new_stylesheet =-\n"
	for line in $(grep -i "\#\([0-9a-f]\{3\}\|[0-9a-f]\{6\}\)" ${old_stylesheet}); do
		# grab the color
		color=$(echo $line | grep -i "\#\([0-9a-f]\{3\}\|[0-9a-f]\{6\}\)" | sed 's/.*\#\([0-9a-f]\{6\}\|[0-9a-f]\{3\}\).*/\#\1/gi')
		if [[ "$color" != "" ]]; then
			# replace the color in the stylesheet
			random=$(hex_random $color)
			echo "  -> $color to $random"
			sed -i "s/${color}\(\s\|\;\)/${random}\1/g" $new_stylesheet
		fi
	done
	#echo -e "\n -= Converting Images =-\n"
	#for line in $(grep -i "url(.*)" $old_stylesheet | sed "s/.*('\(.*\)').*/\1/gi"); do
		#old_image=$line
		## Images
		#echo "  -> desaturating: $line"
		#image_desaturate $old_image
		## edit stylesheet
		#new_image=$(echo ${line} | sed 's/\(.*\)\(\.[a-z]\{3,4\}\)$/\1_desaturated\2/i')
		#echo "  -> updating stylesheet to: $new_image"
		#sed -i "s#${old_image}#${new_image}#g" $new_stylesheet
	#done
	echo -e "\n -= COMPLETE! =-\n"
}

function hex_desaturate() {
	echo $1 | sed 's/\#\([0-9a-f]\{1\}\|[0-9a-f]\{2\}\)\([0-9a-f]\{1\}\|[0-9a-f]\{2\}\)\([0-9a-f]\{1\}\|[0-9a-f]\{2\}\)/\1 \2 \3/gi' | sed 's/\([0-9a-f]\)\{1\} \([0-9a-f]\)\{1\} \([0-9a-f]\)\{1\}/\1\1 \2\2 \3\3/gi' | awk '{ printf "%d\n%d\n%d\n\n", "0x" $1, "0x" $2, "0x" $3 }' | sort -g | tail -n1 | awk '{ printf "#%02X%02X%02X\n", $1, $1, $1 }'
}

function hex_random() {
	r=$(number=$RANDOM && let "number %= 255" && echo $number | awk '{ printf "%02X\n", $1 }')
	g=$(number=$RANDOM && let "number %= 255" && echo $number | awk '{ printf "%02X\n", $1 }')
	b=$(number=$RANDOM && let "number %= 255" && echo $number | awk '{ printf "%02X\n", $1 }')
	echo $1 | sed "s/\#\([0-9a-f]\{1\}\|[0-9a-f]\{2\}\)\([0-9a-f]\{1\}\|[0-9a-f]\{2\}\)\([0-9a-f]\{1\}\|[0-9a-f]\{2\}\)/\#${r}${g}${b}/gi"
}

function image_desaturate() {
	old_image=$1
	new_image=$(echo ${1} | sed 's/\(.*\)\(\.[a-z]\{3,4\}\)$/\1_desaturated\2/i')
	convert -fx G $old_image $new_image
}

function image_random() {
	old_image=$1
	new_image=$(echo ${1} | sed 's/\(.*\)\(\.[a-z]\{3,4\}\)$/\1_desaturated\2/i')
	convert -fx G $old_image $new_image
}

# Case swtich to filter params
case $1 in
  -d) css_desaturate $2;;
  -r) css_random $2;;
  --da) convert_all_css $2;;
  #*) css_desaturate;;
esac
