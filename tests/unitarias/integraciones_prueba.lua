local pruebas = require("tests.auxiliar")

pruebas.prueba("los comandos se registran una sola vez e informan sin errores", function()
  local comandos = require("quetzal.comandos")
  comandos.registrar()
  comandos.registrar()
  local disponibles = vim.api.nvim_get_commands({})
  for _, nombre in ipairs({ "QuetzalInfo", "QuetzalSalud", "QuetzalReiniciarLsp" }) do
    pruebas.verdadero(disponibles[nombre] ~= nil, "Falta el comando " .. nombre)
  end
  vim.cmd("QuetzalInfo")
end)

pruebas.prueba("checkhealth Quetzal presenta diagnósticos del entorno", function()
  vim.cmd("checkhealth quetzal")
  pruebas.igual("checkhealth", vim.bo.filetype)
  local contenido = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  pruebas.verdadero(contenido:find("Lenguaje Quetzal", 1, true) ~= nil, contenido)
  pruebas.verdadero(contenido:find("Tree%-sitter") ~= nil, contenido)
  vim.cmd("bwipeout!")
end)

pruebas.prueba("las asignaciones son locales, respetan teclas existentes y capacidades", function()
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buffer)
  vim.keymap.set("n", "K", function() end, { buffer = buffer, desc = "Asignación original" })
  local opciones = require("quetzal.configuracion").valores_predeterminados().asignaciones
  opciones.habilitadas = true
  require("quetzal.asignaciones").registrar(buffer, {
    server_capabilities = { definitionProvider = true, hoverProvider = true },
  }, opciones)

  pruebas.igual(1, vim.fn.maparg("gd", "n", false, true).buffer)
  pruebas.igual("Asignación original", vim.fn.maparg("K", "n", false, true).desc)
  pruebas.igual("", vim.fn.maparg("<leader>qa", "n"))
  pruebas.igual(0, vim.fn.maparg("]d", "n", false, true).buffer)
  vim.cmd("bwipeout!")
end)

pruebas.prueba("Tree-sitter ausente o deshabilitado no produce errores ni afecta al LSP", function()
  local arbol = require("quetzal.arbol_sintaxis")
  local opciones = require("quetzal.configuracion").valores_predeterminados()
  opciones.arbol_sintaxis.habilitado = false
  local buffer = vim.api.nvim_create_buf(false, true)
  pruebas.igual(false, arbol.activar(buffer, opciones))
  pruebas.igual("deshabilitado", arbol.describir(buffer))
  pruebas.igual("boolean", type(arbol.parser_disponible()))
  if #vim.api.nvim_get_runtime_file("parser/quetzal.*", true) == 0 then
    pruebas.igual(false, arbol.parser_disponible())
  end
  vim.api.nvim_buf_delete(buffer, { force = true })
end)
