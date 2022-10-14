FROM fedora:37 AS stage1
WORKDIR /app
RUN dnf install git vala meson gcc libgee-devel json-glib-devel gtk4-devel gtksourceview5-devel libadwaita-devel libpeas-devel g++ template-glib-devel zip -y &&\
    dnf clean all &&\
    git clone https://github.com/JCWasmx86/GNOME-Builder-Plugins
WORKDIR /app/GNOME-Builder-Plugins
RUN meson build -Dc_args="-O2" -Dsmart=disabled &&\
    ninja -C build -j4 &&\
    cp build/dist.zip /app

FROM scratch AS export-stage
COPY --from=stage1 /app/dist.zip .
