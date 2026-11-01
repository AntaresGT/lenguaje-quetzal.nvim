local M = {}

local inicializado = false
local configuracion_actual = nil

function M.esta_inicializado()
  return inicializado
end

function M.guardar(configuracion)
  configuracion_actual = configuracion
  inicializado = true
end

function M.obtener_configuracion()
  return configuracion_actual
end

return M
