local M = {}

local PREDETERMINADAS = {
  lsp = {
    habilitado = true,
    comando = { "quetzal-lsp", "--stdio" },
    configuracion = {},
  },
  arbol_sintaxis = {
    habilitado = true,
    resaltado = true,
    plegado = false,
  },
  sintaxis = {
    habilitada = true,
  },
  diagnosticos = {
    habilitados = true,
  },
  asignaciones = {
    habilitadas = false,
    definicion = "gd",
    hover = "K",
    diagnosticos = "<leader>qd",
    siguiente_diagnostico = "]d",
    anterior_diagnostico = "[d",
    acciones_codigo = "<leader>qa",
  },
  notificaciones = {
    habilitadas = true,
  },
}

local ESQUEMA = {
  lsp = {
    habilitado = "booleano",
    comando = "lista_de_cadenas",
    configuracion = "tabla",
  },
  arbol_sintaxis = {
    habilitado = "booleano",
    resaltado = "booleano",
    plegado = "booleano",
  },
  sintaxis = {
    habilitada = "booleano",
  },
  diagnosticos = {
    habilitados = "booleano",
  },
  asignaciones = {
    habilitadas = "booleano",
    definicion = "cadena_o_falso",
    hover = "cadena_o_falso",
    diagnosticos = "cadena_o_falso",
    siguiente_diagnostico = "cadena_o_falso",
    anterior_diagnostico = "cadena_o_falso",
    acciones_codigo = "cadena_o_falso",
  },
  notificaciones = {
    habilitadas = "booleano",
  },
}

local NOMBRES_TIPOS = {
  booleano = "booleano",
  tabla = "tabla",
  lista_de_cadenas = "lista no vacía de cadenas",
  cadena_o_falso = "cadena o false",
}

local function fallar(ruta, mensaje)
  error(string.format("Configuración de Quetzal: `%s` %s", ruta, mensaje), 0)
end

local function validar_tipo(valor, tipo, ruta)
  if tipo == "booleano" and type(valor) ~= "boolean" then
    fallar(ruta, "debe ser booleano")
  elseif tipo == "tabla" and type(valor) ~= "table" then
    fallar(ruta, "debe ser una tabla")
  elseif tipo == "cadena_o_falso" and type(valor) ~= "string" and valor ~= false then
    fallar(ruta, "debe ser una cadena o false")
  elseif tipo == "cadena_o_falso" and type(valor) == "string" and valor == "" then
    fallar(ruta, "no puede ser una cadena vacía")
  elseif tipo == "lista_de_cadenas" then
    if type(valor) ~= "table" or #valor == 0 then
      fallar(ruta, "debe ser una " .. NOMBRES_TIPOS.lista_de_cadenas)
    end
    for indice, elemento in ipairs(valor) do
      if type(elemento) ~= "string" or elemento == "" then
        fallar(ruta .. "[" .. indice .. "]", "debe ser una cadena no vacía")
      end
    end
    for clave in pairs(valor) do
      if type(clave) ~= "number" or clave < 1 or clave > #valor or clave % 1 ~= 0 then
        fallar(ruta, "debe ser una lista sin claves adicionales")
      end
    end
  end
end

local function validar_tabla(valores, esquema, prefijo)
  for clave, valor in pairs(valores) do
    local ruta = prefijo == "" and tostring(clave) or (prefijo .. "." .. tostring(clave))
    local tipo = esquema[clave]
    if tipo == nil then
      fallar(ruta, "no es una opción reconocida")
    elseif type(tipo) == "table" then
      if type(valor) ~= "table" then
        fallar(ruta, "debe ser una tabla")
      end
      validar_tabla(valor, tipo, ruta)
    else
      validar_tipo(valor, tipo, ruta)
    end
  end
end

local function validar_configuracion_nativa(configuracion)
  if configuracion.cmd ~= nil then
    fallar("lsp.configuracion.cmd", "debe configurarse mediante `lsp.comando`")
  end
  if configuracion.filetypes ~= nil then
    fallar("lsp.configuracion.filetypes", "está reservado para el tipo de archivo `quetzal`")
  end
end

function M.valores_predeterminados()
  return vim.deepcopy(PREDETERMINADAS)
end

function M.combinar(opciones)
  opciones = opciones or {}
  if type(opciones) ~= "table" then
    fallar("setup", "debe recibir una tabla o nil")
  end

  validar_tabla(opciones, ESQUEMA, "")
  validar_configuracion_nativa(opciones.lsp and opciones.lsp.configuracion or {})

  local combinadas = vim.tbl_deep_extend("force", M.valores_predeterminados(), opciones)
  if opciones.lsp and opciones.lsp.comando then
    combinadas.lsp.comando = vim.deepcopy(opciones.lsp.comando)
  end
  return combinadas
end

return M
