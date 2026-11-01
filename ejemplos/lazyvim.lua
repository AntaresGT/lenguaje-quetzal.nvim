-- Guardar como lua/plugins/quetzal.lua en la configuración de LazyVim.
return {
  "AntaresGT/lenguaje-quetzal.nvim",
  version = "^0.1.0",
  main = "quetzal",
  ft = "quetzal",
  init = function()
    vim.filetype.add({ extension = { qz = "quetzal" } })
  end,
  opts = {},
}
