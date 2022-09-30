FROM fedora:36 AS stage1
WORKDIR /app
RUN sudo dnf install git vala meson gcc libgee-devel json-glib-devel gtk4-devel gtksourceview5-devel libadwaita-devel libpeas-devel g++ zip template-glib-devel -y &&\
    git clone https://gitlab.gnome.org/GNOME/libadwaita &&\
    cd libadwaita &&\
    meson build -Dprefix=/usr &&\
    cd build &&\
    sudo ninja install &&\
    cd ../.. &&\
    git clone https://github.com/JCWasmx86/GNOME-Builder-Plugins &&\
    cd GNOME-Builder-Plugins &&\
    meson build &&\
    cd build &&\
    ninja install &&\
    cp dist.zip /app

FROM scratch AS export-stage
COPY --from=stage1 /app/dist.zip .
