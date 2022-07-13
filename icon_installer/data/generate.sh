#!/usr/bin/env bash
{
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	echo "<gresources>"
	echo "<gresource prefix=\"/plugins/icon_installer/\">"
	for i in $(ls icons/scalable/actions); do
		echo "<file>icons/scalable/actions/$i</file>"
	done
	rm -f icons.txt
	for i in $(ls icons/scalable/actions/show-*); do
		echo $i|sed s/.*\\///g|sed s/.svg$//g >> icons.txt
	done
	echo "<file>icons.txt</file>"
	echo "<file>icons.json</file>"
	echo "</gresource>"
	echo "</gresources>"
} | xmllint -format - > icon_installer.gresource.xml
wget https://gitlab.gnome.org/Teams/Design/icon-development-kit/-/raw/main/icons.json