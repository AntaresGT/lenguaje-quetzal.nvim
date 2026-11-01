# Registro de cambios

El formato sigue las ideas de [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto utiliza versionado semántico.

## [0.1.0] - 2026-10-31

Primera versión pública preparada para Neovim 0.11 o superior y compatible con el servidor de la rama `quetzal-0.0.3`.

### Añadido

- API `require("quetzal").setup()` con valores predeterminados, validación en español e inicialización idempotente.
- Configuración nativa `vim.lsp.config()` y `vim.lsp.enable()` para `quetzal-lsp --stdio`.
- Detección de archivos `.qz`, opciones locales y resaltado tradicional provisional basado en el lexer oficial.
- Diagnósticos, cambios sin guardar, completado, hover y navegación a definiciones proporcionados por el servidor real.
- Reutilización de clientes, soporte de archivos individuales y reinicio exclusivo del LSP Quetzal.
- Asignaciones locales opcionales sin sobrescritura de atajos existentes.
- Integración Tree-sitter nativa, condicionada a un parser instalado y a consultas válidas.
- Comandos `:QuetzalInfo`, `:QuetzalSalud` y `:QuetzalReiniciarLsp`.
- Informe `:checkhealth quetzal`.
- Pruebas unitarias e integración real con LSP y lazy.nvim en modo headless.
- Ejemplos para Neovim estándar, NvChad, LazyVim y AstroNvim.
- Documentación integrada, integración continua y configuración de StyLua, LuaLS y Luacheck.

### Limitaciones conocidas

- La gramática `tree-sitter-quetzal` todavía no publica un parser funcional; no se incluye un instalador.
- Las capacidades LSP no anunciadas por el servidor permanecen deshabilitadas.
- La validación local se realizó en Linux; Windows y macOS dependen de las APIs multiplataforma utilizadas, pero requieren verificación adicional.

[0.1.0]: https://github.com/AntaresGT/lenguaje-quetzal.nvim/releases/tag/v0.1.0
