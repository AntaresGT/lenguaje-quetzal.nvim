local M = {}

local utilidades = require("quetzal.utilidades")

local NOMBRE_SERVIDOR = "quetzal"
local GRUPO_EVENTOS = "LenguajeQuetzalLsp"

local function ejecutable_informado(comando, notificaciones)
  local ejecutable = utilidades.resolver_ejecutable(comando)
  if not ejecutable.disponible then
    utilidades.notificar_una_vez(
      "ejecutable:" .. ejecutable.ejecutable,
      ejecutable.mensaje .. "\n" .. utilidades.INSTRUCCIONES_LSP,
      vim.log.levels.WARN,
      notificaciones.habilitadas
    )
  end
  return ejecutable
end

local function al_conectar(evento, opciones)
  local cliente = vim.lsp.get_client_by_id(evento.data.client_id)
  if not cliente or cliente.name ~= NOMBRE_SERVIDOR or vim.bo[evento.buf].filetype ~= "quetzal" then
    return
  end

  if not opciones.diagnosticos.habilitados then
    local espacio = vim.lsp.diagnostic.get_namespace(cliente.id)
    vim.diagnostic.enable(false, { bufnr = evento.buf, ns_id = espacio })
  end

  require("quetzal.asignaciones").registrar(evento.buf, cliente, opciones.asignaciones)
end

function M.habilitar(opciones)
  local ejecutable = ejecutable_informado(opciones.lsp.comando, opciones.notificaciones)
  if not ejecutable.disponible then
    return false
  end

  local correcto, error_activacion = pcall(vim.lsp.enable, NOMBRE_SERVIDOR)
  if not correcto then
    utilidades.notificar(
      "No se pudo activar el servidor Quetzal: " .. tostring(error_activacion),
      vim.log.levels.ERROR,
      opciones.notificaciones.habilitadas
    )
    return false
  end
  return true
end

function M.configurar(opciones)
  if not opciones.lsp.habilitado then
    return false
  end

  local grupo = vim.api.nvim_create_augroup(GRUPO_EVENTOS, { clear = false })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = grupo,
    desc = "Configurar únicamente los buffers de Lenguaje Quetzal",
    callback = function(evento)
      al_conectar(evento, opciones)
    end,
  })

  local configuracion = vim.tbl_deep_extend("force", {
    cmd = vim.deepcopy(opciones.lsp.comando),
    filetypes = { "quetzal" },
    root_markers = { "quetzal.json", ".git" },
    workspace_required = false,
  }, opciones.lsp.configuracion)
  configuracion.cmd = vim.deepcopy(opciones.lsp.comando)
  configuracion.filetypes = { "quetzal" }

  vim.lsp.config(NOMBRE_SERVIDOR, configuracion)
  return M.habilitar(opciones)
end

function M.clientes(buffer)
  local filtro = { name = NOMBRE_SERVIDOR }
  if buffer then
    filtro.bufnr = buffer
  end
  return vim.lsp.get_clients(filtro)
end

function M.obtener_raiz(buffer)
  local clientes = M.clientes(buffer)
  if clientes[1] and clientes[1].root_dir then
    return clientes[1].root_dir
  end

  local correcto, raiz = pcall(vim.fs.root, buffer, { "quetzal.json", ".git" })
  return correcto and raiz or nil
end

function M.reiniciar()
  local estado = require("quetzal.estado")
  local opciones = estado.obtener_configuracion()
  if not opciones then
    utilidades.notificar("Ejecuta `require('quetzal').setup()` antes de reiniciar el LSP.", vim.log.levels.WARN)
    return false
  end
  if not opciones.lsp.habilitado then
    utilidades.notificar("El LSP de Quetzal está deshabilitado en la configuración.", vim.log.levels.WARN)
    return false
  end
  if not ejecutable_informado(opciones.lsp.comando, opciones.notificaciones).disponible then
    return false
  end

  vim.lsp.enable(NOMBRE_SERVIDOR, false)
  local detenido = vim.wait(3000, function()
    return #M.clientes() == 0
  end, 50)
  if not detenido then
    utilidades.notificar(
      "El servidor Quetzal no se detuvo a tiempo; no se iniciará otro cliente.",
      vim.log.levels.ERROR,
      opciones.notificaciones.habilitadas
    )
    return false
  end

  local habilitado = M.habilitar(opciones)
  if habilitado then
    utilidades.notificar(
      "Servidor LSP de Quetzal reiniciado.",
      vim.log.levels.INFO,
      opciones.notificaciones.habilitadas
    )
  end
  return habilitado
end

return M
