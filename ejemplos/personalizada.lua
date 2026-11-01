require("quetzal").setup({
  lsp = {
    comando = { "/ruta/absoluta/quetzal-lsp", "--stdio" },
  },
  arbol_sintaxis = {
    habilitado = true,
    resaltado = true,
    plegado = false,
  },
  asignaciones = {
    habilitadas = true,
    definicion = "gd",
    hover = "K",
    acciones_codigo = false,
  },
})
