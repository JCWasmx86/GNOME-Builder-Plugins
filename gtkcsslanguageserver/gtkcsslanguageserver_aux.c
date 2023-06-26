#include "libide-lsp.h"

extern GType gtk_css_language_server_service_get_type(void) G_GNUC_CONST;

void bind_client(IdeObject *obj) {
  g_autoptr(IdeLspServiceClass) clazz =
      g_type_class_ref(gtk_css_language_server_service_get_type());
  ide_lsp_service_class_bind_client(clazz, obj);
}

