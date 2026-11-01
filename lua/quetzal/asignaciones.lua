local M = {}

local function saltar_diagnostico(cantidad)
  return function()
    vim.diagnostic.jump({ count = cantidad, float = true })
  end
end

local DEFINICIONES = {
  definicion = {
    capacidad = "definitionProvider",
    descripcion = "Ir a la definición",
    accion = function()
      vim.lsp.buf.definition()
    end,
  },
  hover = {
    capacidad = "hoverProvider",
    descripcion = "Mostrar información del símbolo",
    accion = function()
      vim.lsp.buf.hover()
    end,
  },
  diagnosticos = {
    descripcion = "Mostrar diagnósticos de la línea",
    accion = function()
      vim.diagnostic.open_float()
    end,
  },
  siguiente_diagnostico = {
    descripcion = "Ir al diagnóstico siguiente",
    accion = saltar_diagnostico(1),
  },
  anterior_diagnostico = {
    descripcion = "Ir al diagnóstico anterior",
    accion = saltar_diagnostico(-1),
  },
  acciones_codigo = {
    capacidad = "codeActionProvider",
    descripcion = "Mostrar acciones de código",
    accion = function()
      vim.lsp.buf.code_action()
    end,
  },
}

local function esta_disponible(cliente, capacidad)
  return capacidad == nil or cliente.server_capabilities[capacidad] ~= nil
end

function M.registrar(buffer, cliente, opciones)
  if not opciones.habilitadas then
    return
  end

  for nombre, definicion in pairs(DEFINICIONES) do
    local teclas = opciones[nombre]
    if teclas and esta_disponible(cliente, definicion.capacidad) then
      local existente = vim.fn.maparg(teclas, "n", false, true)
      if vim.tbl_isempty(existente) then
        vim.keymap.set("n", teclas, definicion.accion, {
          buffer = buffer,
          silent = true,
          desc = "Quetzal: " .. definicion.descripcion,
        })
      end
    end
  end
end

return M
