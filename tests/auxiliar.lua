local M = {
  total = 0,
  fallos = {},
}

local function texto(valor)
  return vim.inspect(valor, { newline = " ", indent = "" })
end

function M.igual(esperado, actual, mensaje)
  if not vim.deep_equal(esperado, actual) then
    error(
      (mensaje and mensaje .. "\n" or "") .. "Se esperaba " .. texto(esperado) .. ", pero se obtuvo " .. texto(actual),
      2
    )
  end
end

function M.verdadero(valor, mensaje)
  if not valor then
    error(mensaje or "Se esperaba un valor verdadero", 2)
  end
end

function M.falla_con(patron, accion)
  local correcto, mensaje = pcall(accion)
  M.verdadero(not correcto, "Se esperaba un error que contuviera: " .. patron)
  M.verdadero(
    tostring(mensaje):find(patron, 1, true) ~= nil,
    "El error no contiene el texto esperado: " .. tostring(mensaje)
  )
end

function M.prueba(nombre, accion)
  M.total = M.total + 1
  local correcto, mensaje = xpcall(accion, debug.traceback)
  if correcto then
    io.stdout:write("OK  " .. nombre .. "\n")
  else
    table.insert(M.fallos, { nombre = nombre, mensaje = mensaje })
    io.stderr:write("FALLO  " .. nombre .. "\n" .. mensaje .. "\n")
  end
end

function M.finalizar()
  io.stdout:write(string.format("Resultado: %d pruebas, %d fallos.\n", M.total, #M.fallos))
  if #M.fallos > 0 then
    vim.cmd("cquit 1")
  end
end

return M
