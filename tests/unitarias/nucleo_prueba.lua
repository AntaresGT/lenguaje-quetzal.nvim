local pruebas = require("tests.auxiliar")

pruebas.prueba("setup es idempotente y no duplica autocmds", function()
  local quetzal = require("quetzal")
  local primera = quetzal.setup({
    lsp = { habilitado = false },
    arbol_sintaxis = { habilitado = false },
  })
  local function contar_eventos(grupo)
    local correcto, eventos = pcall(vim.api.nvim_get_autocmds, { group = grupo })
    return correcto and #eventos or 0
  end
  local eventos_lsp = contar_eventos("LenguajeQuetzalLsp")
  local eventos_arbol = contar_eventos("LenguajeQuetzalArbolSintaxis")
  local segunda = quetzal.setup({ lsp = { habilitado = true } })

  pruebas.verdadero(primera == segunda, "Debe conservarse la primera configuración")
  pruebas.igual(false, segunda.lsp.habilitado)
  pruebas.igual(eventos_lsp, contar_eventos("LenguajeQuetzalLsp"))
  pruebas.igual(eventos_arbol, contar_eventos("LenguajeQuetzalArbolSintaxis"))
end)

pruebas.prueba("un archivo nuevo .qz activa filetype y opciones locales", function()
  vim.cmd("edit archivo_unitario_sin_guardar.qz")
  pruebas.igual("quetzal", vim.bo.filetype)
  pruebas.igual("// %s", vim.bo.commentstring)
  pruebas.igual(4, vim.bo.shiftwidth)
  pruebas.igual(4, vim.bo.tabstop)
  pruebas.igual(4, vim.bo.softtabstop)
  pruebas.igual(true, vim.bo.expandtab)
  pruebas.igual("quetzal", vim.b.current_syntax)
  vim.cmd("bwipeout!")
end)

pruebas.prueba("la resolución distingue ejecutables disponibles y ausentes", function()
  local utilidades = require("quetzal.utilidades")
  local disponible = utilidades.resolver_ejecutable({ vim.v.progpath })
  local ausente = utilidades.resolver_ejecutable({ "quetzal-ejecutable-inexistente-para-pruebas" })
  pruebas.igual(true, disponible.disponible)
  pruebas.verdadero(disponible.ruta ~= "")
  pruebas.igual(false, ausente.disponible)
  pruebas.verdadero(ausente.mensaje:find("permisos de ejecución", 1, true) ~= nil)
end)

pruebas.prueba("la ausencia del ejecutable no impide setup ni deshabilita otras funciones", function()
  local servidor = require("quetzal.servidor")
  local opciones = require("quetzal.configuracion").combinar({
    lsp = { comando = { "quetzal-ejecutable-inexistente-para-pruebas", "--stdio" } },
    notificaciones = { habilitadas = false },
  })
  pruebas.igual(false, servidor.habilitar(opciones))
end)
