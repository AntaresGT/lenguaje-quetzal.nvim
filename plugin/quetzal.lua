if vim.g.cargado_lenguaje_quetzal == 1 then
  return
end
vim.g.cargado_lenguaje_quetzal = 1

vim.filetype.add({ extension = { qz = "quetzal" } })
require("quetzal.comandos").registrar()
