local M = {}

local avisos_emitidos = {}

M.INSTRUCCIONES_LSP =
  "Instala el servidor desde la rama quetzal-0.0.3 con `cargo install --path crates/lsp --locked`, o configura `lsp.comando` con su ruta."

function M.notificar(mensaje, nivel, habilitadas)
  if habilitadas == false then
    return
  end
  vim.notify(mensaje, nivel or vim.log.levels.INFO, { title = "Lenguaje Quetzal" })
end

function M.notificar_una_vez(clave, mensaje, nivel, habilitadas)
  if avisos_emitidos[clave] then
    return
  end
  avisos_emitidos[clave] = true
  M.notificar(mensaje, nivel, habilitadas)
end

function M.resolver_ejecutable(comando)
  if type(comando) ~= "table" or type(comando[1]) ~= "string" or comando[1] == "" then
    return {
      disponible = false,
      ejecutable = "",
      ruta = "",
      mensaje = "El comando LSP debe comenzar con una ruta o un nombre de ejecutable.",
    }
  end

  local ejecutable = comando[1]
  local disponible = vim.fn.executable(ejecutable) == 1
  local ruta = disponible and vim.fn.exepath(ejecutable) or ""
  return {
    disponible = disponible,
    ejecutable = ejecutable,
    ruta = ruta ~= "" and ruta or ejecutable,
    mensaje = disponible and "Ejecutable disponible."
      or ("No se encontró un ejecutable con permisos de ejecución: " .. ejecutable),
  }
end

function M.comando_como_texto(comando)
  if type(comando) ~= "table" then
    return "no configurado"
  end
  return table.concat(comando, " ")
end

function M.version_nvim()
  local version = vim.version()
  return string.format("%d.%d.%d", version.major, version.minor, version.patch)
end

return M
