local fuente = debug.getinfo(1, "S").source:sub(2)
local raiz = vim.fn.fnamemodify(vim.fs.dirname(vim.fs.dirname(fuente)), ":p")
vim.opt.runtimepath:prepend(raiz)
package.path = raiz .. "/?.lua;" .. raiz .. "/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

local archivos = {
  "unitarias/configuracion_prueba.lua",
  "unitarias/nucleo_prueba.lua",
  "unitarias/integraciones_prueba.lua",
}

for _, archivo in ipairs(archivos) do
  dofile(raiz .. "/tests/" .. archivo)
end

require("tests.auxiliar").finalizar()
vim.cmd("qa!")
