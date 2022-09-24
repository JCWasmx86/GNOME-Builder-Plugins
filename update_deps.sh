#!/usr/bin/env bash
basedir=$(mktemp -d)
cd $basedir
mkdir prefix
git clone https://gitlab.gnome.org/GNOME/libpanel
cd libpanel
meson build -Dprefix=$basedir/prefix
cd build
ninja install
cd ../..
git clone https://gitlab.gnome.org/GNOME/template-glib
cd template-glib
meson build -Dprefix=$basedir/prefix
cd build
ninja install
cd ../..
git clone https://gitlab.gnome.org/GNOME/vte
cd vte
meson build -Dprefix=$basedir/prefix -Dgtk4=true
cd build
ninja install
cd ../..
mkdir vapi
cp prefix/share/vala/vapi/vte-2.91-gtk4.vapi vapi/vte-3.91.vapi
cp prefix/share/vala/vapi/libpanel-1.vapi vapi/panel-1.vapi
cp prefix/share/vala/vapi/template-glib-1.0.vapi vapi/
mkdir include/
cp -R prefix/include/{template-glib-1.0,libpanel-1} include/
cp -R prefix/include/vte-2.91-gtk4/ include/vte-2.91
echo "The vapis and headers are in $basedir/include and $basedir/vapi now"