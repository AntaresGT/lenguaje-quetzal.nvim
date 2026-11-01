# Notas de versión v0.1.0

Primera versión del plugin oficial Lenguaje Quetzal para Neovim.

## Aspectos destacados

- Integración nativa con `quetzal-lsp --stdio`, sin `nvim-lspconfig`.
- Diagnósticos, autocompletado, hover y definiciones del servidor oficial de la rama `quetzal-0.0.3`.
- Detección temprana de `.qz` y carga diferida comprobada con lazy.nvim.
- Compatibilidad de configuración con NvChad, LazyVim, AstroNvim y Neovim estándar.
- Resaltado tradicional provisional y detección opcional de Tree-sitter.
- Comandos de información, salud y reinicio, además de pruebas headless y CI.

## Instalación

Instala primero el servidor con `cargo install --path crates/lsp --locked` desde el repositorio del lenguaje. Después declara `AntaresGT/lenguaje-quetzal.nvim` con lazy.nvim siguiendo el README.

## Verificación de la entrega

En Linux, tanto con Neovim 0.12.6 como con la versión mínima 0.11.4, se ejecutaron correctamente:

- 12 pruebas unitarias en cada versión.
- Integración con el binario real: apertura, UTF-16, proyecto y archivo individual, diagnósticos, cambios sin guardar, completado, hover, definición, reutilización, cierre y reinicio sin afectar a otro cliente.
- Integración real con lazy.nvim: detección temprana y carga por filetype.
- Compilación e instalación del servidor con el comando de CI.
- Compilación sintáctica de los 25 archivos Lua y comprobación de formato con StyLua.

## Limitaciones

- `tree-sitter-quetzal` aún no ofrece una gramática funcional publicada; el resaltado Tree-sitter y el plegado quedan condicionados a su disponibilidad.
- Referencias, renombrado, formateo, acciones de código y otras capacidades no anunciadas por el servidor no forman parte de esta versión.
- Windows y macOS no fueron verificados localmente.
- La rama `quetzal-0.0.3` examinada informa internamente la versión de paquete `0.0.2` durante la inicialización LSP.
