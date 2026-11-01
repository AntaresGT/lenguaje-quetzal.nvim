-- Añadir a init.lua después de instalar el plugin como paquete nativo de inicio.
require("quetzal").setup({
  lsp = {
    habilitado = true,
    comando = { "quetzal-lsp", "--stdio" },
  },
})
