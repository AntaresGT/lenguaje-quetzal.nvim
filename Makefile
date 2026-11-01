NVIM ?= nvim
STYLUA ?= stylua
LUACHECK ?= luacheck
ARCHIVOS_LUA := lua lsp plugin ftplugin tests ejemplos

.PHONY: formato formato-verificar analisis pruebas pruebas-unitarias pruebas-lsp pruebas-lazy verificar

formato:
	$(STYLUA) $(ARCHIVOS_LUA)

formato-verificar:
	$(STYLUA) --check $(ARCHIVOS_LUA)

analisis:
	$(LUACHECK) lua lsp plugin ftplugin tests ejemplos

pruebas-unitarias:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/ejecutar_unitarias.lua

pruebas-lsp:
	QUETZAL_LSP_REQUERIDO=$${QUETZAL_LSP_REQUERIDO:-0} $(NVIM) --headless -u NONE -i NONE -n -l tests/integracion/lsp_prueba.lua

pruebas-lazy:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/integracion/lazy_prueba.lua

pruebas: pruebas-unitarias pruebas-lsp pruebas-lazy

verificar: formato-verificar analisis pruebas
