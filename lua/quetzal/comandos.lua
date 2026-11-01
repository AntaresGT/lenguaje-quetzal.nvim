local M = {}

local registrados = false

local function crear_comando(nombre, accion, descripcion)
  if vim.fn.exists(":" .. nombre) == 2 then
    require("quetzal.utilidades").notificar_una_vez(
      "comando:" .. nombre,
      "No se registró :" .. nombre .. " porque ya existe un comando con ese nombre.",
      vim.log.levels.WARN
    )
    return
  end
  vim.api.nvim_create_user_command(nombre, accion, { desc = descripcion })
end

local function informacion()
  local estado = require("quetzal.estado")
  local configuracion = require("quetzal.configuracion")
  local servidor = require("quetzal.servidor")
  local utilidades = require("quetzal.utilidades")
  local buffer = vim.api.nvim_get_current_buf()
  local opciones = estado.obtener_configuracion() or configuracion.valores_predeterminados()
  local ejecutable = utilidades.resolver_ejecutable(opciones.lsp.comando)
  local clientes_globales = servidor.clientes()
  local clientes_buffer = servidor.clientes(buffer)

  local lineas = {
    "Lenguaje Quetzal para Neovim",
    "Versión del plugin: " .. require("quetzal").VERSION,
    "Versión de Neovim: " .. utilidades.version_nvim(),
    "Inicialización: " .. (estado.esta_inicializado() and "completada" or "setup() pendiente"),
    "LSP configurado: " .. (opciones.lsp.habilitado and "habilitado" or "deshabilitado"),
    "Comando LSP: " .. utilidades.comando_como_texto(opciones.lsp.comando),
    "Ejecutable: " .. (ejecutable.disponible and ejecutable.ruta or "no disponible"),
    "Clientes LSP activos: " .. #clientes_globales,
    "Tipo de archivo actual: " .. (vim.bo[buffer].filetype ~= "" and vim.bo[buffer].filetype or "sin definir"),
    "Raíz del proyecto: " .. (servidor.obtener_raiz(buffer) or "sin marcadores de proyecto"),
    "Tree-sitter: " .. require("quetzal.arbol_sintaxis").describir(buffer),
  }

  if #clientes_buffer == 0 then
    table.insert(lineas, "Cliente en este buffer: ninguno")
  else
    for _, cliente in ipairs(clientes_buffer) do
      table.insert(
        lineas,
        string.format(
          "Cliente en este buffer: %s (id %d, raíz: %s)",
          cliente.name,
          cliente.id,
          cliente.root_dir or "ninguna"
        )
      )
    end
  end

  vim.api.nvim_echo({ { table.concat(lineas, "\n") } }, true, {})
end

function M.registrar()
  if registrados then
    return
  end
  registrados = true

  crear_comando("QuetzalInfo", informacion, "Mostrar el estado de Lenguaje Quetzal")
  crear_comando("QuetzalSalud", function()
    vim.cmd("checkhealth quetzal")
  end, "Comprobar el entorno de Lenguaje Quetzal")
  crear_comando("QuetzalReiniciarLsp", function()
    require("quetzal.servidor").reiniciar()
  end, "Reiniciar solamente el servidor LSP de Quetzal")
end

return M
