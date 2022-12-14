#!/usr/bin/env bash
{
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	echo "<gresources>"
	echo "<gresource prefix=\"/plugins/icon_installer/\">"
	for i in ./icons/scalable/actions/*.svg; do
		echo "<file preprocess=\"xml-stripblanks\">icons/scalable/actions/$(basename $i)</file>"
	done
	rm -f icons.txt
	for i in ./icons/scalable/actions/show-*; do
		echo $i|sed "s/.*\\///g"|sed s/.svg$//g >> icons.txt
	done
	echo "<file>icons.txt</file>"
	echo "<file>icons.json</file>"
	echo "</gresource>"
	echo "</gresources>"
} | xmllint -format - > icon_installer.gresource.xml