# Guía de contribución

Gracias por contribuir a `lenguaje-quetzal.nvim`.

## Principios

- Conserva la compatibilidad con Neovim 0.11 o superior.
- Escribe identificadores, mensajes y documentación propios en español; respeta los nombres exigidos por las APIs externas.
- Utiliza el LSP oficial como fuente de análisis. No reimplementes el lenguaje ni inventes capacidades que el servidor no anuncie.
- Mantén Tree-sitter como componente opcional y en su repositorio independiente.
- No modifiques configuraciones globales ni instales componentes durante el arranque.
- Evita dependencias nuevas salvo que resuelvan una necesidad demostrable.

## Preparación

Necesitas Neovim 0.11+, StyLua y, para el análisis estático, Luacheck. LuaLS puede usar `.luarc.json` para reconocer `vim` y el entorno LuaJIT.

Las pruebas unitarias no necesitan el servidor. Para las pruebas reales instala `quetzal-lsp` desde la rama `quetzal-0.0.3` siguiendo el README.

```bash
git clone --depth 1 https://github.com/folke/lazy.nvim.git .investigacion/lazy
make formato
make analisis
QUETZAL_LSP_REQUERIDO=1 make pruebas
```

`.investigacion/` está excluido del control de versiones y se usa para dependencias temporales de desarrollo.

## Cambios

1. Explica el comportamiento que quieres modificar y comprueba primero el código o la documentación oficial.
2. Haz cambios pequeños dentro del módulo responsable.
3. Añade o ajusta pruebas automatizadas para el comportamiento afectado.
4. Ejecuta formato, análisis y todas las pruebas disponibles.
5. No declares verificadas plataformas o capacidades que no hayas ejecutado.
6. Actualiza README, ayuda integrada y changelog cuando cambie el comportamiento público.

## Pruebas

- `make pruebas-unitarias`: configuración, inicialización, filetype, ejecutable, comandos, salud, asignaciones y ausencia de Tree-sitter.
- `make pruebas-lsp`: protocolo real, diagnósticos, cambios, completado, hover, definición, clientes y reinicio.
- `make pruebas-lazy`: detección temprana y carga real mediante lazy.nvim.

Las pruebas omitidas por una dependencia ausente se imprimen como `OMITIDA`; no deben presentarse como aprobadas. En CI, la integración LSP compila el servidor oficial y lo exige explícitamente.

## Publicación

Los mantenedores actualizan `CHANGELOG.md`, las notas de versión y la etiqueta SemVer. No se publican releases ni se envían cambios remotos como parte de una contribución local sin autorización.
