#include <libide-lsp.h>

GVariant *
wrap_call_async_finish (IdeLspClient  *self,
                        GAsyncResult  *result,
                        GError       **error)
{
  GVariant *variant;
  if (!ide_lsp_client_call_finish (self, result, &variant, error))
    return NULL;
  return variant;
}
