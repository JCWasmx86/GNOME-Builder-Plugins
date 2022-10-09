FROM fedora:36 AS stage1
WORKDIR /app
RUN dnf install git vala meson gcc libgee-devel json-glib-devel gtk4-devel gtksourceview5-devel libadwaita-devel libpeas-devel g++ template-glib-devel zip -y &&\
    dnf clean all &&\
    git clone https://gitlab.gnome.org/GNOME/libadwaita
WORKDIR /app/libadwaita
RUN meson build -Dprefix=/usr &&\
    ninja -C build install
WORKDIR /app
RUN git clone https://github.com/JCWasmx86/GNOME-Builder-Plugins
WORKDIR /app/GNOME-Builder-Plugins
RUN meson build -Dc_args="-O2" &&\
    ninja -C build -j4 &&\
    cp build/dist.zip /app

FROM scratch AS export-stage
COPY --from=stage1 /app/dist.zip .
