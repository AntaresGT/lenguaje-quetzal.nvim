local fuente = debug.getinfo(1, "S").source:sub(2)
local raiz = vim.fn.fnamemodify(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(fuente))), ":p")
vim.opt.runtimepath:prepend(raiz)
vim.cmd("filetype plugin indent on")

local function afirmar(valor, mensaje)
  if not valor then
    error(mensaje, 2)
  end
end

local function esperar(condicion, mensaje)
  afirmar(vim.wait(10000, condicion, 50), mensaje)
end

local function solicitar(cliente, buffer, metodo, parametros)
  local respuesta
  cliente.request(cliente, metodo, parametros, function(error, resultado)
    afirmar(not error, "Error en " .. metodo .. ": " .. vim.inspect(error))
    respuesta = resultado
  end, buffer)
  esperar(function()
    return respuesta ~= nil
  end, "No llegó la respuesta de " .. metodo)
  return respuesta
end

local function parametros_posicion(buffer, linea, caracter)
  return {
    textDocument = { uri = vim.uri_from_bufnr(buffer) },
    position = { line = linea, character = caracter },
  }
end

local function iniciar_cliente_auxiliar(buffer, directorio)
  local terminado = false
  local cliente_id = vim.lsp.start({
    name = "auxiliar_prueba_quetzal",
    root_dir = directorio,
    cmd = function(despachadores)
      return {
        request = function(metodo, _, responder)
          if metodo == "initialize" then
            responder(nil, { capabilities = {} })
          elseif metodo == "shutdown" then
            responder(nil, nil)
          end
          return true, 1
        end,
        notify = function(metodo)
          if metodo == "exit" then
            terminado = true
            despachadores.on_exit(0, 0)
          end
          return true
        end,
        is_closing = function()
          return terminado
        end,
        terminate = function()
          terminado = true
          despachadores.on_exit(0, 0)
        end,
      }
    end,
  }, {
    bufnr = buffer,
    reuse_client = function()
      return false
    end,
  })
  afirmar(cliente_id ~= nil, "No se pudo iniciar el cliente auxiliar")
  return cliente_id
end

local directorio = raiz .. "/.investigacion/pruebas/integracion"
local buffer
local cliente_auxiliar

local function limpiar()
  pcall(vim.lsp.enable, "quetzal", false)
  if cliente_auxiliar then
    local cliente = vim.lsp.get_client_by_id(cliente_auxiliar)
    if cliente then
      pcall(cliente.stop, cliente)
    end
  end
  pcall(vim.cmd, "silent! %bwipeout!")
  pcall(vim.fn.delete, directorio, "rf")
end

if vim.fn.executable("quetzal-lsp") ~= 1 then
  if vim.env.QUETZAL_LSP_REQUERIDO == "1" then
    error("La prueba requiere quetzal-lsp en PATH o QUETZAL_LSP_REQUERIDO=0.")
  end
  io.stdout:write("OMITIDA: quetzal-lsp no está instalado; las pruebas unitarias no dependen de él.\n")
  vim.cmd("qa!")
end

local correcto, error_prueba = xpcall(function()
  vim.fn.mkdir(directorio, "p")
  vim.fn.writefile({ "{}" }, directorio .. "/quetzal.json")
  local archivo = directorio .. "/principal.qz"
  vim.fn.writefile({ "entero var saldo = 10" }, archivo)

  require("quetzal").setup({
    arbol_sintaxis = { habilitado = false },
    notificaciones = { habilitadas = false },
  })
  require("quetzal.comandos").registrar()
  vim.cmd("edit " .. vim.fn.fnameescape(archivo))
  buffer = vim.api.nvim_get_current_buf()
  afirmar(vim.bo.filetype == "quetzal", "No se detectó el filetype Quetzal")

  local cliente
  esperar(function()
    cliente = vim.lsp.get_clients({ name = "quetzal", bufnr = buffer })[1]
    return cliente and cliente.initialized
  end, "El servidor real no terminó initialize")
  afirmar(vim.fs.normalize(cliente.root_dir) == vim.fs.normalize(directorio), "La raíz del proyecto es incorrecta")
  afirmar(cliente.offset_encoding == "utf-16", "No se negoció UTF-16")
  afirmar(cliente.server_capabilities.completionProvider ~= nil, "Falta completionProvider")
  afirmar(cliente.server_capabilities.hoverProvider == true, "Falta hoverProvider")
  afirmar(cliente.server_capabilities.definitionProvider == true, "Falta definitionProvider")
  afirmar(cliente.server_capabilities.renameProvider == nil, "El servidor no debe anunciar renombrado")

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { 'entero valor = "texto"' })
  esperar(function()
    local diagnosticos = vim.diagnostic.get(buffer)
    return diagnosticos[1] and diagnosticos[1].code == "E0204"
  end, "No llegó el diagnóstico semántico del cambio sin guardar")
  afirmar(vim.bo[buffer].modified, "El documento debería permanecer sin guardar")

  local programa = {
    "entero var saldo = 10",
    "entero sumar(entero a, entero b) {",
    "    retornar a + b",
    "}",
    "saldo = 20",
    "sumar(1, 2)",
  }
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, programa)
  esperar(function()
    return #vim.diagnostic.get(buffer) == 0
  end, "No se limpiaron los diagnósticos tras corregir el documento")

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "entero total = 1", "tot" })
  local completado = solicitar(cliente, buffer, "textDocument/completion", parametros_posicion(buffer, 1, 3))
  local encontrado = false
  for _, elemento in ipairs(completado) do
    if elemento.label == "total" and elemento.detail == "entero total" then
      encontrado = true
    end
  end
  afirmar(encontrado, "El completado real no incluyó el símbolo total")

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, programa)
  local hover = solicitar(cliente, buffer, "textDocument/hover", parametros_posicion(buffer, 4, 2))
  afirmar(
    hover and hover.contents and hover.contents.value:find("entero var saldo", 1, true),
    "Hover no devolvió el tipo esperado"
  )

  local definicion = solicitar(cliente, buffer, "textDocument/definition", parametros_posicion(buffer, 4, 2))
  afirmar(definicion and definicion.range.start.line == 0, "La definición no apunta a la primera línea")
  afirmar(definicion.range.start.character == 11, "La definición no apunta al identificador")

  local segundo_archivo = directorio .. "/segundo.qz"
  vim.fn.writefile({ "entero segundo = 2" }, segundo_archivo)
  vim.cmd("edit " .. vim.fn.fnameescape(segundo_archivo))
  local segundo_buffer = vim.api.nvim_get_current_buf()
  esperar(function()
    return #vim.lsp.get_clients({ name = "quetzal", bufnr = segundo_buffer }) == 1
  end, "El segundo buffer no se conectó")
  afirmar(#vim.lsp.get_clients({ name = "quetzal" }) == 1, "Se creó un cliente duplicado para la misma raíz")
  vim.cmd("bwipeout!")
  afirmar(vim.api.nvim_buf_is_valid(buffer), "El buffer principal no debería cerrarse")

  cliente_auxiliar = iniciar_cliente_auxiliar(buffer, directorio)
  local id_anterior = cliente.id
  vim.api.nvim_set_current_buf(buffer)
  vim.cmd("QuetzalReiniciarLsp")
  local cliente_nuevo
  esperar(function()
    cliente_nuevo = vim.lsp.get_clients({ name = "quetzal", bufnr = buffer })[1]
    return cliente_nuevo and cliente_nuevo.initialized and cliente_nuevo.id ~= id_anterior
  end, "El reinicio no creó un único cliente nuevo")
  afirmar(#vim.lsp.get_clients({ name = "quetzal" }) == 1, "El reinicio duplicó clientes")
  afirmar(vim.lsp.get_client_by_id(cliente_auxiliar) ~= nil, "El reinicio afectó a otro servidor")

  vim.cmd("bwipeout!")
  esperar(function()
    return #vim.lsp.get_clients({ name = "quetzal", bufnr = buffer }) == 0
  end, "El cierre del buffer no lo desconectó del LSP")

  vim.cmd("enew")
  local buffer_individual = vim.api.nvim_get_current_buf()
  vim.bo[buffer_individual].filetype = "quetzal"
  local cliente_individual
  esperar(function()
    cliente_individual = vim.lsp.get_clients({ name = "quetzal", bufnr = buffer_individual })[1]
    return cliente_individual and cliente_individual.initialized
  end, "Un buffer individual sin proyecto no pudo iniciar el LSP")
  afirmar(cliente_individual.offset_encoding == "utf-16", "El buffer individual no negoció UTF-16")
  vim.cmd("bwipeout!")

  io.stdout:write(
    "OK  integración real: filetype, proyecto y archivo individual, diagnósticos, cambios, completado, hover, definición, reutilización, cierre y reinicio.\n"
  )
end, debug.traceback)

limpiar()
if not correcto then
  io.stderr:write(tostring(error_prueba) .. "\n")
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
