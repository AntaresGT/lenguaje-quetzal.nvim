local M = {}

local estados = setmetatable({}, { __mode = "k" })

local function parser_disponible()
  local correcto, cargado = pcall(vim.treesitter.language.add, "quetzal")
  return correcto and cargado == true
end

local function activar_plegado(buffer)
  local correcto, consulta = pcall(vim.treesitter.query.get, "quetzal", "folds")
  if not correcto or not consulta or vim.api.nvim_get_current_buf() ~= buffer then
    return false
  end

  vim.wo[0].foldmethod = "expr"
  vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  return true
end

function M.parser_disponible()
  return parser_disponible()
end

function M.activar(buffer, opciones)
  if not vim.api.nvim_buf_is_valid(buffer) then
    return false
  end
  if not opciones.arbol_sintaxis.habilitado then
    estados[buffer] = "deshabilitado"
    return false
  end
  if not parser_disponible() then
    estados[buffer] = "parser no instalado"
    return false
  end

  if opciones.arbol_sintaxis.resaltado then
    local correcto, error_resaltado = pcall(vim.treesitter.start, buffer, "quetzal")
    if not correcto then
      estados[buffer] = "error: " .. tostring(error_resaltado)
      return false
    end
    vim.bo[buffer].syntax = ""
  else
    local correcto = pcall(vim.treesitter.get_parser, buffer, "quetzal")
    if not correcto then
      estados[buffer] = "no se pudo inicializar el parser"
      return false
    end
  end

  local plegado = opciones.arbol_sintaxis.plegado and activar_plegado(buffer)
  estados[buffer] = plegado and "activo con plegado" or "activo"
  return true
end

function M.describir(buffer)
  return estados[buffer] or (parser_disponible() and "disponible, no activado" or "parser no instalado")
end

function M.configurar(opciones)
  local grupo = vim.api.nvim_create_augroup("LenguajeQuetzalArbolSintaxis", { clear = false })
  vim.api.nvim_create_autocmd("FileType", {
    group = grupo,
    pattern = "quetzal",
    desc = "Activar Tree-sitter de Quetzal cuando exista el parser",
    callback = function(evento)
      vim.b[evento.buf].quetzal_sintaxis_deshabilitada = not opciones.sintaxis.habilitada
      M.activar(evento.buf, opciones)
    end,
  })

  local buffer = vim.api.nvim_get_current_buf()
  if vim.bo[buffer].filetype == "quetzal" then
    vim.b[buffer].quetzal_sintaxis_deshabilitada = not opciones.sintaxis.habilitada
    vim.schedule(function()
      M.activar(buffer, opciones)
    end)
  end
end

return M
