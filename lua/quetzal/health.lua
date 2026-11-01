local M = {}

local function comprobar_neovim()
  if vim.fn.has("nvim-0.11") == 1 then
    vim.health.ok("Neovim " .. require("quetzal.utilidades").version_nvim() .. " es compatible.")
  else
    vim.health.error("Se requiere Neovim 0.11 o superior.", {
      "Actualiza Neovim antes de utilizar lenguaje-quetzal.nvim.",
    })
  end
end

local function comprobar_filetype()
  local tipo = vim.filetype.match({ filename = "comprobacion.qz" })
  if tipo == "quetzal" then
    vim.health.ok("Los archivos .qz se reconocen como filetype=quetzal.")
  else
    vim.health.error("No se reconoce la extensión .qz.", {
      "Carga el plugin durante el arranque o registra `qz = 'quetzal'` con vim.filetype.add().",
      "Con lazy.nvim y carga por filetype, conserva la función `init` del ejemplo de instalación.",
    })
  end
end

local function comprobar_lsp(opciones)
  if not opciones.lsp.habilitado then
    vim.health.info("El LSP está deshabilitado por la configuración del usuario; no se exige el ejecutable.")
    return
  end

  local utilidades = require("quetzal.utilidades")
  local ejecutable = utilidades.resolver_ejecutable(opciones.lsp.comando)
  if ejecutable.disponible then
    vim.health.ok("Ejecutable LSP: " .. ejecutable.ruta .. " (permisos de ejecución correctos).")
  else
    vim.health.error(ejecutable.mensaje, {
      utilidades.INSTRUCCIONES_LSP,
      "En Windows puedes indicar la ruta completa de quetzal-lsp.exe en `lsp.comando`.",
    })
  end

  local configuracion = vim.lsp.config.quetzal
  if not configuracion then
    vim.health.error("No existe la configuración nativa `quetzal`.", {
      "Ejecuta require('quetzal').setup() y revisa que lsp/quetzal.lua esté en runtimepath.",
    })
  elseif not vim.tbl_contains(configuracion.filetypes or {}, "quetzal") then
    vim.health.error("La configuración LSP no incluye el tipo de archivo `quetzal`.")
  else
    vim.health.ok("La configuración nativa `quetzal` incluye el filetype correcto.")
  end

  local clientes = require("quetzal.servidor").clientes()
  if #clientes == 0 then
    vim.health.info("No hay clientes LSP de Quetzal conectados; abre un archivo .qz para iniciar uno.")
  else
    for _, cliente in ipairs(clientes) do
      vim.health.ok(string.format("Cliente LSP id %d conectado; raíz: %s.", cliente.id, cliente.root_dir or "ninguna"))
    end
  end
end

local function comprobar_arbol(opciones)
  if not opciones.arbol_sintaxis.habilitado then
    vim.health.info("Tree-sitter está deshabilitado por la configuración; el LSP no depende de él.")
    return
  end
  if require("quetzal.arbol_sintaxis").parser_disponible() then
    vim.health.ok("El parser Tree-sitter `quetzal` está disponible.")
  else
    vim.health.info("El parser opcional `quetzal` no está instalado; se utilizará el resaltado tradicional.", {
      "El LSP seguirá funcionando con normalidad.",
      "Cuando se publique, instala el parser desde https://github.com/AntaresGT/tree-sitter-quetzal.",
      "nvim-treesitter main requiere Neovim 0.12; master es la rama heredada para Neovim 0.11.",
    })
  end
end

function M.check()
  local estado = require("quetzal.estado")
  local opciones = estado.obtener_configuracion() or require("quetzal.configuracion").valores_predeterminados()

  vim.health.start("Lenguaje Quetzal")
  comprobar_neovim()
  comprobar_filetype()
  if not estado.esta_inicializado() then
    vim.health.info("setup() todavía no se ha ejecutado; se comprobarán los valores predeterminados.")
  end
  comprobar_lsp(opciones)
  comprobar_arbol(opciones)
end

return M
