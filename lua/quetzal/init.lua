local M = {}

M.VERSION = "0.1.0"

function M.registrar_tipo_archivo()
  vim.filetype.add({ extension = { qz = "quetzal" } })
end

function M.setup(opciones)
  local estado = require("quetzal.estado")
  if estado.esta_inicializado() then
    return estado.obtener_configuracion()
  end

  if vim.fn.has("nvim-0.11") ~= 1 then
    error("Lenguaje Quetzal requiere Neovim 0.11 o superior.", 0)
  end

  local configuracion = require("quetzal.configuracion").combinar(opciones)
  M.registrar_tipo_archivo()
  require("quetzal.servidor").configurar(configuracion)
  require("quetzal.arbol_sintaxis").configurar(configuracion)
  estado.guardar(configuracion)
  return configuracion
end

return M
