if exists("b:current_syntax") || (exists("b:quetzal_sintaxis_deshabilitada") && b:quetzal_sintaxis_deshabilitada)
  finish
endif

syntax case match
syntax match quetzalComentario "//.*$"
syntax match quetzalEscape +\\[ntr"\\{}]+ contained
syntax match quetzalInterpolacion +{[^}]*}+ contained
syntax region quetzalCadena start=+"+ skip=+\\.+ end=+"+ oneline contains=quetzalEscape
syntax region quetzalPlantilla start=+\<t"+ skip=+\\.+ end=+"+ oneline contains=quetzalEscape,quetzalInterpolacion
syntax match quetzalNumero "\<[0-9]\+\(\.[0-9]\+\)\=\>"

syntax keyword quetzalTipo entero número numero texto log lista jsn vacío vacio
syntax keyword quetzalControl si sino mientras para hacer en cada romper continuar retornar
syntax keyword quetzalExcepcion intentar capturar finalmente lanzar excepción excepcion
syntax keyword quetzalObjeto objeto prototipo hereda implementa como nuevo esto padre
syntax keyword quetzalModificador público publico privado libre opcional var
syntax keyword quetzalAsincrono asincróno asincrono esperar
syntax keyword quetzalModulo importar exportar desde
syntax keyword quetzalOperador y o
syntax keyword quetzalLiteral verdadero falso nulo

highlight default link quetzalComentario Comment
highlight default link quetzalEscape SpecialChar
highlight default link quetzalInterpolacion Special
highlight default link quetzalCadena String
highlight default link quetzalPlantilla String
highlight default link quetzalNumero Number
highlight default link quetzalTipo Type
highlight default link quetzalControl Conditional
highlight default link quetzalExcepcion Exception
highlight default link quetzalObjeto Structure
highlight default link quetzalModificador StorageClass
highlight default link quetzalAsincrono Keyword
highlight default link quetzalModulo Include
highlight default link quetzalOperador Operator
highlight default link quetzalLiteral Constant

let b:current_syntax = "quetzal"
