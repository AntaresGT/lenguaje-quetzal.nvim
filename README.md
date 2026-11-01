# lenguaje-quetzal.nvim

Plugin oficial de [Lenguaje Quetzal](https://github.com/AntaresGT/lenguaje-quetzal) para Neovim. Integra el servidor LSP escrito en Rust, reconoce archivos `.qz`, ofrece resaltado tradicional provisional y queda preparado para la futura gramática Tree-sitter.

No depende de NvChad, `nvim-lspconfig`, Node.js, VS Code, motores de completado ni Tree-sitter.

## Requisitos

- Neovim **0.11 o superior**.
- El ejecutable oficial `quetzal-lsp`, si se desea utilizar el LSP.
- lazy.nvim es opcional; también puede usarse el sistema nativo de paquetes de Neovim.

El plugin funciona en Linux, Windows y macOS mediante APIs multiplataforma de Neovim. La verificación automatizada descrita al final se realizó en Linux; no se afirma una validación local en Windows o macOS.

## Funcionalidades

### Disponibles con `quetzal-lsp` de la rama `quetzal-0.0.3`

- Inicialización y ciclo de vida mediante las APIs nativas `vim.lsp.config()` y `vim.lsp.enable()`.
- Negociación de posiciones UTF-16.
- Sincronización completa de documentos abiertos y cambios sin guardar.
- Diagnósticos léxicos, sintácticos y semánticos publicados por el servidor.
- Autocompletado LSP de palabras clave, símbolos y miembros.
- Información de símbolos con `vim.lsp.buf.hover()`.
- Navegación a definiciones con `vim.lsp.buf.definition()`.
- Reutilización de clientes por proyecto y funcionamiento en archivos individuales.
- Reinicio exclusivo del cliente Quetzal.

### Disponibles sin componentes adicionales

- Detección de `.qz` como `filetype=quetzal`, incluso antes de la carga diferida con lazy.nvim.
- Comentarios `//` e indentación local de cuatro espacios.
- Resaltado tradicional provisional con palabras clave reales del lexer.
- Comandos `:QuetzalInfo`, `:QuetzalSalud` y `:QuetzalReiniciarLsp`.
- Informe `:checkhealth quetzal`.
- Asignaciones locales opcionales que no sobrescriben teclas existentes.

### Opcionales y futuras

- Tree-sitter se activa únicamente si ya existe un parser `quetzal` válido. El LSP nunca depende de él.
- El plegado Tree-sitter solo se habilita cuando se solicita y existe una consulta `folds` válida.
- Referencias, renombrado, firma de funciones, formateo, acciones de código, símbolos e inlay hints dependen de futuras versiones del servidor. La versión examinada **no anuncia esas capacidades** y el plugin no las simula.

## Instalar el servidor LSP

El plugin no compila Rust, no descarga binarios y no realiza instalaciones al abrir Neovim.

```bash
git clone --branch quetzal-0.0.3 --depth 1 \
  https://github.com/AntaresGT/lenguaje-quetzal.git
cd lenguaje-quetzal
cargo install --path crates/lsp --locked
```

El comando instala `quetzal-lsp` en el directorio de binarios de Cargo, normalmente `~/.cargo/bin` en Linux/macOS o `%USERPROFILE%\.cargo\bin` en Windows. Ese directorio debe estar en `PATH`.

Comprobación:

```bash
quetzal-lsp --stdio
```

Ese comando espera mensajes LSP en la entrada estándar; para salir puede cerrarse la entrada o terminar el proceso. No es necesario tener Rust en tiempo de ejecución una vez instalado el binario. También puede configurarse una ruta absoluta, incluida una ruta a `quetzal-lsp.exe` en Windows.

La rama de referencia se llama `quetzal-0.0.3`; en el código examinado, el paquete del workspace todavía informa la versión `0.0.2` durante `initialize`.

## Instalación con lazy.nvim

Configuración recomendada para Neovim estándar:

```lua
{
  "AntaresGT/lenguaje-quetzal.nvim",
  version = "^0.1.0",
  main = "quetzal",
  ft = "quetzal",
  cmd = { "QuetzalInfo", "QuetzalSalud", "QuetzalReiniciarLsp" },
  init = function()
    -- Necesario para reconocer .qz antes de cargar el plugin por filetype.
    vim.filetype.add({ extension = { qz = "quetzal" } })
  end,
  opts = {},
}
```

`opts = {}` ejecuta `require("quetzal").setup({})`. La función `init` se ejecuta durante el arranque; la detección temprana evita el ciclo en el que el plugin esperaría un filetype que todavía no puede descubrirse. `ftdetect/quetzal.vim` proporciona una segunda vía nativa, no una carga pesada adicional.

Hay ejemplos completos en [`ejemplos/`](ejemplos/).

### NvChad

Crea `lua/plugins/quetzal.lua` en tu configuración de NvChad con el contenido de [`ejemplos/nvchad.lua`](ejemplos/nvchad.lua):

```lua
return {
  {
    "AntaresGT/lenguaje-quetzal.nvim",
    version = "^0.1.0",
    main = "quetzal",
    ft = "quetzal",
    init = function()
      vim.filetype.add({ extension = { qz = "quetzal" } })
    end,
    opts = {},
  },
}
```

NvChad importa las especificaciones de `lua/plugins/` mediante lazy.nvim. No se modifica su núcleo, su tema ni su configuración de completado.

### LazyVim

Coloca la misma especificación en `lua/plugins/quetzal.lua`. LazyVim importa ese directorio automáticamente. No es necesario añadir el servidor a una lista de Mason ni utilizar `lspconfig`.

### AstroNvim

En una configuración basada en la plantilla actual de AstroNvim, crea `lua/plugins/quetzal.lua` con la especificación de [`ejemplos/astronvim.lua`](ejemplos/astronvim.lua). El servidor se instala por separado, no mediante `:LspInstall`.

### Neovim estándar, sin gestor de plugins

Instala el repositorio como paquete nativo. Ejemplo para Linux/macOS:

```bash
mkdir -p ~/.local/share/nvim/site/pack/quetzal/start
git clone https://github.com/AntaresGT/lenguaje-quetzal.nvim.git \
  ~/.local/share/nvim/site/pack/quetzal/start/lenguaje-quetzal.nvim
```

En Windows puede utilizarse el directorio equivalente `~/AppData/Local/nvim-data/site/pack/quetzal/start/`.

Después añade a `init.lua`:

```lua
require("quetzal").setup()
```

Al cargarse como paquete de inicio, `plugin/quetzal.lua` registra el filetype antes de abrir archivos.

## Configuración

Valores predeterminados:

```lua
require("quetzal").setup({
  lsp = {
    habilitado = true,
    comando = { "quetzal-lsp", "--stdio" },
    configuracion = {},
  },
  arbol_sintaxis = {
    habilitado = true,
    resaltado = true,
    plegado = false,
  },
  sintaxis = {
    habilitada = true,
  },
  diagnosticos = {
    habilitados = true,
  },
  asignaciones = {
    habilitadas = false,
    definicion = "gd",
    hover = "K",
    diagnosticos = "<leader>qd",
    siguiente_diagnostico = "]d",
    anterior_diagnostico = "[d",
    acciones_codigo = "<leader>qa",
  },
  notificaciones = {
    habilitadas = true,
  },
})
```

| Opción | Tipo | Predeterminado | Comportamiento |
|---|---|---|---|
| `lsp.habilitado` | booleano | `true` | Activa el LSP si el ejecutable está disponible. |
| `lsp.comando` | lista no vacía de cadenas | `{ "quetzal-lsp", "--stdio" }` | Ejecutable y argumentos, sin pasar por un shell. |
| `lsp.configuracion` | tabla | `{}` | Opciones adicionales de `vim.lsp.Config`, como `capabilities` o `root_markers`. |
| `arbol_sintaxis.habilitado` | booleano | `true` | Permite detectar y usar un parser ya instalado. |
| `arbol_sintaxis.resaltado` | booleano | `true` | Activa el resaltado Tree-sitter cuando hay parser. |
| `arbol_sintaxis.plegado` | booleano | `false` | Activa plegado solo si existe la consulta `folds`. |
| `sintaxis.habilitada` | booleano | `true` | Controla el resaltado tradicional provisional. |
| `diagnosticos.habilitados` | booleano | `true` | Si es `false`, deshabilita solo el espacio de diagnósticos del LSP Quetzal en sus buffers. |
| `asignaciones.habilitadas` | booleano | `false` | Registra las asignaciones opcionales al conectar el LSP. |
| `asignaciones.*` | cadena o `false` | Ver tabla anterior | Define o desactiva cada asignación. |
| `notificaciones.habilitadas` | booleano | `true` | Controla avisos del plugin; no silencia errores de validación ni informes solicitados. |

`lsp.configuracion.cmd` y `lsp.configuracion.filetypes` están reservados: utiliza `lsp.comando` y el filetype `quetzal`. No se cambian las capacidades globales de otros servidores. Las configuraciones de `nvim-cmp` o `blink.cmp` pueden aportar capacidades mediante sus mecanismos habituales; ninguno es obligatorio. Sin motor externo puede usarse el completado omnifunc nativo de Neovim.

Las opciones desconocidas o con tipos incorrectos producen un error descriptivo. Una segunda llamada a `setup()` conserva la primera configuración y no duplica autocmds ni clientes.

### Ejecutable y argumentos personalizados

```lua
require("quetzal").setup({
  lsp = {
    comando = { "/ruta/absoluta/quetzal-lsp", "--stdio" },
  },
})
```

En Windows, por ejemplo:

```lua
lsp = {
  comando = { [[C:\Herramientas\Quetzal\quetzal-lsp.exe]], "--stdio" },
}
```

### Diagnósticos

Neovim conserva tu configuración de signos, texto virtual, colores y navegación. Personalízala con `vim.diagnostic.config()` como harías para otros servidores; el plugin no reemplaza esos estilos.

## Atajos sugeridos

Las asignaciones están deshabilitadas de forma predeterminada. Al activarlas se crean solo para buffers Quetzal, cuando existe la capacidad correspondiente y no hay otra asignación con esas teclas.

| Acción | Tecla sugerida | Disponibilidad |
|---|---|---|
| Ir a definición | `gd` | Servidor actual. |
| Información del símbolo | `K` | Servidor actual. |
| Mostrar diagnósticos | `<leader>qd` | Diagnósticos de Neovim. |
| Diagnóstico siguiente | `]d` | Neovim; no reemplaza su asignación global. |
| Diagnóstico anterior | `[d` | Neovim; no reemplaza su asignación global. |
| Acciones de código | `<leader>qa` | Reservada: el servidor actual no las anuncia. |

Para usar únicamente algunas:

```lua
asignaciones = {
  habilitadas = true,
  hover = "K",
  definicion = "gd",
  acciones_codigo = false,
}
```

## Comandos

### `:QuetzalInfo`

Muestra versión del plugin y de Neovim, estado de `setup()`, comando y ejecutable LSP, número de clientes, filetype actual, raíz, Tree-sitter y clientes conectados al buffer.

### `:QuetzalSalud`

Abre directamente `:checkhealth quetzal`; no duplica la infraestructura de salud.

### `:QuetzalReiniciarLsp`

Detiene y vuelve a habilitar únicamente la configuración `quetzal`. Espera a que terminen los clientes anteriores para evitar duplicados. No afecta a servidores de otros lenguajes.

## Tree-sitter

El repositorio arquitectónico es [AntaresGT/tree-sitter-quetzal](https://github.com/AntaresGT/tree-sitter-quetzal). En el momento de preparar esta versión contiene documentación inicial, pero no una gramática publicada y verificable. Por eso el plugin:

- no incluye `grammar.js`, C generado ni consultas inventadas;
- no instala parsers automáticamente;
- no usa `get_parser_configs()`;
- utiliza `vim.treesitter.language.add()`, `vim.treesitter.start()` y `vim.treesitter.query.get()`;
- mantiene el LSP y el resaltado tradicional si el parser no existe.

Cuando haya una gramática publicada, instálala según sus instrucciones y las de tu rama de `nvim-treesitter`. La rama moderna `main` requiere Neovim 0.12 o superior; la rama heredada `master` está dirigida a Neovim 0.10/0.11. No mezcles APIs de ambas. Este plugin no necesita `nvim-treesitter` para detectar un parser que ya esté en `runtimepath`.

## Solución de problemas

### El LSP no inicia o el ejecutable no está en `PATH`

Ejecuta `:checkhealth quetzal` y `:QuetzalInfo`. Comprueba la instalación con `vim.fn.executable("quetzal-lsp")` o configura una ruta absoluta en `lsp.comando`. El plugin emite un único aviso por ejecutable ausente y deja el resto del editor operativo. Si instalas el binario después de abrir Neovim, ejecuta `:QuetzalReiniciarLsp`.

### Un archivo `.qz` no se reconoce

Con carga por `ft`, conserva la función `init` del ejemplo. Ejecuta `:lua print(vim.filetype.match({ filename = "archivo.qz" }))`; debe devolver `quetzal`. Revisa que no exista otra regla posterior que lo sustituya.

### El autocompletado no aparece

Confirma que hay un cliente con `:QuetzalInfo`. El servidor actual ofrece completado, pero la interfaz depende de tu configuración: usa tu motor (`nvim-cmp`, `blink.cmp`, etc.) o el completado nativo de Neovim. No hace falta instalar un analizador adicional.

### Los diagnósticos no aparecen

Revisa `diagnosticos.habilitados`, tu configuración global de `vim.diagnostic` y el contenido del buffer. El servidor publica diagnósticos al abrir y al cambiar el documento, incluso sin guardar.

### Tree-sitter no está instalado

Es una dependencia opcional. El LSP y la sintaxis tradicional siguen funcionando. `:checkhealth quetzal` lo informa sin convertirlo en un error crítico.

### El servidor se detiene inesperadamente

Revisa `:LspLog`, `:QuetzalInfo` y los mensajes de Neovim. Después usa `:QuetzalReiniciarLsp`. Si el ejecutable ya no está disponible, el plugin no intentará crear clientes repetidamente.

## Desarrollo

Arquitectura:

- `lua/quetzal/init.lua`: API pública e inicialización.
- `configuracion.lua`: predeterminados, combinación y validación.
- `estado.lua`: estado mínimo de inicialización.
- `servidor.lua`: configuración, conexión, raíz y reinicio LSP.
- `asignaciones.lua`: atajos locales condicionados por capacidades.
- `arbol_sintaxis.lua`: integración Tree-sitter nativa y opcional.
- `comandos.lua`: comandos de usuario.
- `health.lua`: comprobaciones de salud.
- `utilidades.lua`: notificaciones y resolución de ejecutables compartidas.
- `plugin/`, `ftdetect/`, `ftplugin/`, `syntax/` y `lsp/`: integraciones reconocidas por Neovim.

Herramientas:

```bash
make formato          # Aplica StyLua.
make formato-verificar
make analisis         # Requiere Luacheck.
make pruebas-unitarias
make pruebas-lsp      # Usa el servidor real o informa que se omite.
make pruebas-lazy     # Requiere una copia local de lazy.nvim o informa que se omite.
make pruebas
make verificar
```

Para exigir el servidor real en la prueba:

```bash
QUETZAL_LSP_REQUERIDO=1 make pruebas-lsp
```

Para la prueba de carga diferida:

```bash
git clone --depth 1 https://github.com/folke/lazy.nvim.git .investigacion/lazy
make pruebas-lazy
```

Las pruebas son headless, no requieren interacción y distinguen explícitamente las omisiones por dependencias ausentes. La integración LSP utiliza ejemplos reales y valida diagnósticos, cambios sin guardar, completado, hover, definición, reutilización, archivo individual, cierre y reinicio sin afectar a otro cliente.

Consulta [`CONTRIBUTING.md`](CONTRIBUTING.md), [`CHANGELOG.md`](CHANGELOG.md) y las notas de [`v0.1.0`](NOTAS_V0.1.0.md). El versionado del plugin sigue SemVer y es independiente del versionado del intérprete.

## Licencia

MIT. Consulta [`LICENSE`](LICENSE).
