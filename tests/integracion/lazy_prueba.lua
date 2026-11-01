local fuente = debug.getinfo(1, "S").source:sub(2)
local raiz = vim.fn.fnamemodify(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(fuente))), ":p")
local ruta_lazy = vim.env.QUETZAL_LAZY_RUTA or (raiz .. "/.investigacion/lazy")

local function afirmar(valor, mensaje)
  if not valor then
    error(mensaje, 2)
  end
end

if vim.fn.isdirectory(ruta_lazy) ~= 1 then
  io.stdout:write("OMITIDA: defina QUETZAL_LAZY_RUTA con una copia local de lazy.nvim.\n")
  vim.cmd("qa!")
end

local directorio = raiz .. "/.investigacion/pruebas/lazy"
vim.fn.mkdir(directorio, "p")
vim.opt.runtimepath:prepend(ruta_lazy)
vim.go.loadplugins = true
vim.cmd("filetype plugin indent on")

local correcto, error_prueba = xpcall(function()
  require("lazy").setup({
    {
      dir = raiz,
      name = "lenguaje-quetzal.nvim",
      main = "quetzal",
      ft = "quetzal",
      init = function()
        vim.filetype.add({ extension = { qz = "quetzal" } })
      end,
      opts = {
        lsp = { habilitado = false },
        arbol_sintaxis = { habilitado = false },
      },
    },
  }, {
    root = directorio .. "/plugins",
    lockfile = directorio .. "/lazy-lock.json",
    install = { missing = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = { rtp = { reset = false } },
  })

  afirmar(package.loaded["quetzal"] == nil, "El plugin se cargó antes de abrir un archivo Quetzal")
  local archivo = directorio .. "/nuevo.qz"
  local detectado = vim.filetype.match({ filename = archivo })
  afirmar(detectado == "quetzal", "init no registró .qz; filetype.match devolvió: " .. vim.inspect(detectado))
  vim.cmd("edit " .. vim.fn.fnameescape(archivo))
  afirmar(
    vim.bo.filetype == "quetzal",
    "lazy.nvim no recibió el filetype Quetzal; filetype.match devolvió: "
      .. vim.inspect(vim.filetype.match({ filename = archivo }))
  )
  afirmar(package.loaded["quetzal"] ~= nil, "El archivo .qz no activó la carga diferida")
  afirmar(require("quetzal.estado").obtener_configuracion().lsp.habilitado == false, "No se aplicaron opts")
  afirmar(vim.fn.exists(":QuetzalInfo") == 2, "No se registraron los comandos tras la carga diferida")
  io.stdout:write("OK  integración real con lazy.nvim: init registra .qz y ft carga el plugin.\n")
end, debug.traceback)

pcall(vim.cmd, "silent! %bwipeout!")
pcall(vim.fn.delete, directorio, "rf")
if not correcto then
  io.stderr:write(tostring(error_prueba) .. "\n")
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
