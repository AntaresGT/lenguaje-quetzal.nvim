-- Guardar como lua/plugins/quetzal.lua en la configuración de NvChad.
return {
  {
    "AntaresGT/lenguaje-quetzal.nvim",
    version = "^0.1.0",
    main = "quetzal",
    ft = "quetzal",
    cmd = { "QuetzalInfo", "QuetzalSalud", "QuetzalReiniciarLsp" },
    init = function()
      vim.filetype.add({ extension = { qz = "quetzal" } })
    end,
    opts = {
      asignaciones = {
        habilitadas = false,
      },
    },
  },
}
