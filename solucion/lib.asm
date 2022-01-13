global intCmp
global intClone
global intDelete
global intPrint
global strCmp
global strClone
global strDelete
global strPrint
global strLen
global arrayNew
global arrayGetSize
global arrayAddLast
global arrayGet
global arrayRemove
global arraySwap
global arrayDelete
global listNew
global listGetSize
global listAddFirst
global listGet
global listRemove
global listSwap
global listClone
global listDelete
global cardNew
global cardGetSuit
global cardGetNumber
global cardGetStacked
global cardCmp
global cardClone
global cardAddStacked
global cardDelete
global cardPrint

;---------------------------------------------------------------------------------

extern fprintf
extern malloc
extern free
extern getCloneFunction
extern getDeleteFunction
extern getCompareFunction
extern getPrintFunction
extern listPrint


;---------------------------------------------------------------------------------

%define ArrayType 0
%define ArraySize 4
%define ArrayCapacity 5
%define ArrayData 8

%define ListType 0
%define ListSize 4
%define ListFirst 8
%define ListLast 16

%define ListElemData 0
%define ListElemNext 8
%define ListElemPrev 16

%define CardSuit 0
%define CardNumber 8
%define CardStacked 16

;---------------------------------------------------------------------------------

section .data

formatofprintf: db '%d'  , 0
formatofprintfstring: db '%s' , 0
NULL: db 'NULL', 0
corcheteOpen: db '{', 0
corcheteClose: db '}', 0
guion: db'-', 0
;---------------------------------------------------------------------------------

section .text

;----------------------------------------------------------------

; ** Int **

;------------------------------------------------------

; int32_t intCmp(int32_t* a, int32_t* b)
; a => rdi
; b => rsi

intCmp:
;armo stackframe
	push rbp
	mov rbp, rsp

;programa
	mov edi, [rdi]
	mov esi, [rsi]

	cmp edi, esi

	JE .iguales
	JG .aMayor
	JMP .bMayor
    
.iguales:
	mov eax, 0
	jmp .fin 

.aMayor:
	mov eax, -1
	jmp .fin

.bMayor:
	mov eax, 1
	jmp .fin 

.fin:
;desarmamos stackframe
    pop rbp

    ret

;------------------------------------------------------

; int32_t* intClone(int32_t* a)
;a -> rdi

intClone:
;armamos stack frame
	push rbp
	mov rbp, rsp
	push rbx
	push r12 ; alineamos

;programa
	mov ebx, [rdi]

	mov rdi, 4	

	call malloc

	mov [rax], ebx

;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp
	ret

;------------------------------------------------------

; void intDelete(int32_t* a)
;a-> rdi

intDelete:
;armamos stackframe
	push rbp
	mov rbp,rsp

;programa
	call free
;desarmamos stackframe
	pop rbp
	ret

;------------------------------------------------------


; void intPrint(int32_t* a, FILE* pFile)
;a-> rdi
;pFile -> rsi

intPrint:
;armamos stackframe
	push rbp
	mov rbp,rsp

;programa
	mov edx, [rdi]
	mov rdi, rsi
	mov rsi, formatofprintf
	
	call fprintf

;desarmamos stackframe
	mov rax, 0
	pop rbp
	ret

;------------------------------------------------------

; ** String **

; char* strClone(char* a)
; a->rdi
strClone:
	;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12

	;programa
	mov rbx, rdi
	call strLen ; tenemos en eax la longitud del string
	inc eax ;incrementamos para dejar espacio al cero
	mov edi, eax ; ponemos parametros para malloc
	call malloc	; tenemos el nuevo puntero a string en rax
	mov r12, rax
	xor rcx, rcx ; ponemos contador en cero

.loop:

	mov sil, [rbx+rcx]
	mov [rax+rcx] , sil
	cmp sil, 0
	je .fin
	inc ecx
	jmp .loop

.fin:
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp

ret

;------------------------------------------------------

; uint32_t strLen(char* a)
; a->rdi
strLen:
	;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	xor rcx, rcx ;ponemos en cero el contador
.loop:

	cmp byte [rdi+rcx], 0
	je .fin
	inc rcx
	jmp .loop
	
.fin:
	mov eax, ecx	;dado que pusimos rcx en 0, podemos devolver su parte baja sin problemas
	;desarmamos stackframe
	pop rbp
	ret

;------------------------------------------------------

; int32_t strCmp(char* a, char* b)
; a->rdi
; b->rsi
;si a>b => -1 ; si a<b => 1 ; si b = a => 0
strCmp:
;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	xor ecx,ecx ; ponemos contador en 0
	xor eax,eax

	.loop:
	mov cl, [rdi]
	mov dl, [rsi]

	cmp cl, dl	;comparamos lexicograficamente caracter a caracter
	jg .mayor	;en el caso de que una palabra sea mas larga, salta a mayor porque compara 0 con un caracter mayor a 0
	jl .menor	;igual que arriba

	cmp cl, 0 ; si paso el cmp anterior son iguales, asi que si uno es 0 se llego al final del string
	je .igual

	inc rdi ;avanzamos al caracter siguiente
	inc rsi ;idem
	jmp .loop

.mayor:
	mov eax, -1
	jmp .fin

.menor:
	mov eax, 1
	jmp .fin
.igual:
	mov eax, 0
	jmp .fin


	

	
.fin:
	;desarmamos stackframe
	pop rbp

ret

;------------------------------------------------------

; void strDelete(char* a)
strDelete:
;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	call free
	
	;desarmamos stackframe
	pop rbp

	ret

;------------------------------------------------------

; void strPrint(char* a, FILE* pFile)
; a -> rdi
; pFile -> rsi 
strPrint:
;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	cmp byte [rdi], 0
	je .null

	mov rdx, rdi
	mov rdi, rsi
	mov rsi, formatofprintfstring
	
	call fprintf

	mov rax, 0	

	jmp .final

.null:
	mov rdx, NULL
	mov rdi, rsi
	mov rsi, formatofprintfstring
	
	call fprintf

	mov rax, 0	

.final:
	;desarmamos stackframe
	pop rbp


ret

;------------------------------------------------------

; ** Array **

;class array(){
;type_t type;			||	4 bytes => 0-4
;uint8_t size;			||	1 byte	=> 4-5	 
;uint8_t capacity;		||	1 byte  => 5-6
;void** data;			|| 	8 bytes => 8-16
;}						||	termina en 16


;------------------------------------------------------

; array_t* arrayNew(type_t t, uint8_t capacity)

;TypeNone = 0,
;TypeInt = 1,
;TypeString = 2,
;TypeCard = 3

;t -> edi -> ebx 
;capacity -> sil -> r12l
arrayNew:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	;programa
	mov ebx, edi
	mov r12b, sil
	
	mov edi, 16 
	call malloc	; reservamos espacio para crear array

	mov [rax+ArrayType], ebx
	mov [rax+ArrayCapacity], r12b
	mov byte [rax+ArraySize], 0
	mov rbx, rax ; preservamos puntero a array
	;necesitamos crear la estructura donde se guardan los punteros a elementos

	xor rdi, rdi
	mov dil, r12b
	shl rdi, 3
	call malloc ; llamamos a malloc reservando 8*capacity

	xor rcx, rcx ; ponemos contador en 0
	mov rdx, rcx

.limpiar:
	mov qword [rax+rdx], 0 ;vamos seteando los punteros a NULL
	add rdx, 8
	inc cl
	cmp cl, r12b	;armamos contador
	je .limpio
	jmp .limpiar	;loop

.limpio:

	mov [rbx + ArrayData], rax ; conectamos array con la estructura de punteros

	mov rax, rbx
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp

ret

;------------------------------------------------------

; uint8_t  arrayGetSize(array_t* a)
; a -> rdi
arrayGetSize:
;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	mov al, [rdi+ArraySize] ;movemos el size usando el offset 

	;desarmamos stackframe
	pop rbp

ret

;------------------------------------------------------

; void  arrayAddLast(array_t* a, void* data)
; a-> rdi
; data -> rsi
arrayAddLast:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12

	;programa
	mov dl, [rdi+ArraySize] 	;chequeamos si el array tiene lugar
	cmp dl, [rdi+ArrayCapacity]
	je .final

	mov rbx, rdi
	mov r12, rsi
	mov edi, [rdi+ArrayType]
	call getCloneFunction ; obtenemos la funcion para copiar el dato

	mov rdi, r12
	call rax ;llamamos a la funcion correspondiente


	xor rdi, rdi
	mov dil, [rbx+ArraySize] ;calculamos el offset donde ira el dato (ya sabemos que el array tiene capacidad)
	shl rdi, 3
	
	mov rcx, [rbx + ArrayData] ;conseguimos el puntero a los datos

	mov [rcx+rdi], rax ; escribimos el nuevo dato
	
	inc byte [rbx+ArraySize]
	;primero hacemos copia


.final:
	xor rax, rax
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp
ret

;------------------------------------------------------

; void* arrayGet(array_t* a, uint8_t i)
; a-> rdi
;i -> sil
arrayGet:
;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	xor rax, rax
	cmp sil, [rdi+ArraySize] ;primero vemos si estamos en rango
	jge .final

	mov dl, sil
	xor rsi, rsi
	mov sil, dl
		
	mov rax, [rdi+ArrayData] 
	shl rsi, 3
	mov rax, [rax+rsi]

	
.final:
	;desarmamos stackframe
	pop rbp
ret


;------------------------------------------------------

; void* arrayRemove(array_t* a, uint8_t i)
; a-> rdi
; i -> sil
arrayRemove:
;armamos el stackframe
	push rbp

	;programa
	mov rbp,rsp
	cmp sil, [rdi+ArraySize] ; verificamos si i esta fuera de rango, en tal caso devolvemos 0
	jge .fueraDeRango

	;buscamos puntero del elemento a remover y lo ponemos en rax
	xor rcx,rcx
	mov cl, sil
	xor rsi, rsi
	mov sil, cl

	mov rdx, [rdi+ArrayData]
	shl rsi, 3
	mov rax, [rdx+rsi]
	mov r8, rsi					; creamos registro que va apuntando una posicion adelante al indice en rsi
	add r8, 8

	;movemos los datos una posicion hacia atras, a partir de la posicion i+1
	;en rdx tenemos el principio de la estructura del array y en rsi el i
	;el contador suma de a 1 hasta llegar al size, luego hay dos punteros, uno va por delante del otro en el array

	.loop:

	inc rcx 	;incrementamos contador 

	cmp cl, [rdi+ArraySize]

	je .ponerCero ; el puntero al ultimo lugar quedo en rsi
	
	mov r9, [rdx+r8]
	mov [rdx+rsi], r9


	add rsi, 8	;incrementamos el puntero que va mas atras
	add r8, 8 	; incrementamos el puntero que va mas adelante

	jmp .loop


.ponerCero:
	;ponemos en 0 la ultima posicion antes de los ceros o el final
	mov qword [rdx+rsi], 0

	;cambiamos el valor de size
	dec byte [rdi + ArraySize] 

	jmp .final
	

.fueraDeRango:
	xor rax,rax

.final:
	;desarmamos stackframe
	pop rbp
ret

;------------------------------------------------------

; void  arraySwap(array_t* a, uint8_t i, uint8_t j)
; a-> rdi
; i -> sil
; j -> dl
arraySwap:
	;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	cmp sil, [rdi+ArraySize] ;vemos si los indices se pasan de rango
	jge .fueraDeRango

	cmp dl, [rdi+ArraySize]
	jge .fueraDeRango

	mov rcx, [rdi+ArrayData] ; puntero a estructura del array
	xor r8,r8 ; guardamos los indices en otros registros limpios para despues multiplicar por 8 y usarlos
	xor r9,r9
	mov r8b, sil
	mov r9b, dl
	shl r8, 3
	shl r9, 3
	;swap
	mov rdi, [rcx+r8]
	mov rsi, [rcx + r9]
	mov [rcx+r8], rsi
	mov [rcx+r9], rdi

.fueraDeRango:
	
	;desarmamos stackframe
	pop rbp

ret

;------------------------------------------------------

; void arrayDelete(array_t* a)
; a -> rdi

arrayDelete:
	;armamos el stackframe
    push rbp
    mov rbp, rsp     
    push rbx
    push r12
    push r13
	push r14

	;programa
    mov rbx, rdi 			; nos guardamos rdi
	xor r12, r12
    mov r12b, [rdi + ArraySize]  

    .ciclo: 	;vamos loopeando y borrando con arrayRemove y la funcion de borrado del tipo
    mov rdi, rbx
    cmp r12b, 0
    je .final
    dec r12b
    mov rsi, r12
    call arrayRemove
    mov r13, rax
    mov edi, [rbx+ArrayType]
    call getDeleteFunction
    mov rdi, r13
    call rax
    jmp .ciclo

    .final:
    mov rdi, rbx 				;una vez que terminamos de borrar los elementos debemos borrar la estructura data y el array
    mov rdi, [rdi+ArrayData]
    call free
    mov rdi, rbx
    call free
    

	;desarmamos stackframe
	pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret



;------------------------------------------------------------------------------------------------------------------------------------


; ** Lista **


; typedef struct s_list {		|| 0
; type_t type					|| 4 bytes => 0 a 4
; uint8_t size					|| 1 bytes => 4 a 5
; struct s_listElem* first;		|| 8 bytes => 8 a 16
; struct s_listElem* last;		|| 8 bytes => 16 a 24
; } list_t;						|| 24

; typedef struct s_listElem {	|| 0
; void* data;					|| 8 bytes => 0 a 8
; struct s_listElem* next;		|| 8 bytes => 8 a 16
; struct s_listElem* prev;		|| 8 bytes => 16 a 24
; } listElem_t;					|| 24



;------------------------------------------------------


; list_t* listNew(type_t t)
; t -> edi
listNew:
	;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12

	;programa
	mov ebx, edi	;preservamos el edi
	
	mov rdi, 24
	call malloc		;guardamos espacio para la estructura list | tenemos en rax el puntero a list

	mov [rax+ListType], ebx
	mov byte [rax+ListSize], 0
	mov qword [rax+ListFirst], 0
	mov qword [rax+ListLast], 0
	
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp
ret

;------------------------------------------------------

; uint8_t  listGetSize(list_t* l)
; l -> rdi
listGetSize:
	;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	mov al, [rdi+ListSize]	

	
	;desarmamos stackframe
	pop rbp
ret

; ;------------------------------------------------------



; void listAddFirst(list_t* l, void* data)
; l -> rdi
; ; data -> rsi
listAddFirst:
	;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	;programa
	mov rbx, rdi	;preservamos registros
	mov r12, rsi

	;inicializar el elem nuevo

	mov edi, [rbx+ListType]
	call getCloneFunction
	mov rdi, r12
	call rax
	mov r12, rax

	mov rdi, 24
	call malloc ; guardamos espacio para elem y ahora tenemos en rax su puntero

	mov [rax+ListElemData], r12
	mov qword [rax+ListElemPrev], 0
	mov qword [rax+ListElemNext], 0

	
	;siempre hay que conectar el nuevo elem al principio y que apunte al viejo princio
	mov rdi, [rbx+ ListFirst]

	mov [rax+ListElemNext], rdi 


	cmp byte [rbx + ListSize], 0
	jne .noVacia
	mov [rbx+ ListLast], rax	; si la lista esta vacia el nuevo elem es el Last
	jmp .fin

.noVacia:	
	;si el size es mayor a cero entonces el elem que esta primero tiene que conectar su prev al nuevo
	mov rsi, [rax+ ListElemNext]
	mov [rsi+ListElemPrev], rax
	
.fin:
	mov [rbx+ ListFirst], rax


	inc byte [rbx + ListSize]
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp
ret

;------------------------------------------------------

; void* listGet(list_t* l, uint8_t i)
listGet:
; l -> rdi
; i -> sil
	;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	xor rax, rax
	cmp sil, [rdi+ListSize] ;primero comparamos que i este en rango
	jge .final
	
	mov rdi, [rdi+ListFirst]

.loop:
	
	mov rax, [rdi+ListElemData]
	mov rdi, [rdi+ListElemNext]
	
	cmp sil, 0
	je .final
	dec sil
	jmp .loop
	
.final:
	
	;desarmamos stackframe
	pop rbp
ret

;------------------------------------------------------

; void* listRemove(list_t* l, uint8_t i)
; l -> rdi
; i -> sil

listRemove: 
	;armamos el stackframe
    push rbp
    mov rbp, rsp
	push rbx
    push r12

	;programa:
    cmp sil, [rdi+ListSize] 		;nos fijamos si el indice es invalido
    jge .fueraDeRango

    mov rbx, rdi 				

    mov rdx, [rbx + ListFirst] 		
    xor rcx,rcx
    
    .ciclo: 						;loopeamos hasta encontrar el elem buscado
    cmp cl, sil
    je .encontrado
    mov rdx, [rdx + ListFirst]
    inc cl
    jmp .ciclo

    .encontrado: 					;encontramos el elemento asi que hacemos las reconexiones
    mov rsi, [rdx + ListElemPrev]
    mov rdi, [rdx + ListElemNext]

    cmp rsi, 0 						;vemos el caso borde si es no primero
    jne .noPrimero
    mov [rbx + ListFirst], rdi
    jmp .siguiente

    .noPrimero:
    mov [rsi + ListElemNext], rdi

    .siguiente: 					;vemos si es no ultimo
    cmp rdi, 0
    jne .noUltimo
    mov [rbx + ListLast], rsi
    jmp .ajustesFinales

    .noUltimo:
    mov [rdi + ListElemPrev], rsi

    .ajustesFinales: 				;terminamos de restaurar los valores de la lista
    dec byte [rbx + ListSize]
    mov r12, [rdx + ListElemData]
    mov rdi, rdx
    call free
    jmp .final

    .fueraDeRango:
    mov r12, 0

    .final:
    mov rax, r12 					;devolvemos el puntero al elem si es que esta en rango

	;desarmamos el stackframe
    pop r12
	pop rbx
    pop rbp
    ret 


;------------------------------------------------------

; void  listSwap(list_t* l, uint8_t i, uint8_t j)
; l -> rdi
; i -> sil 
; j -> dl
listSwap:
	;armamos el stackframe
	push rbp
	mov rbp,rsp
	push r12
	push r13

	mov r12, rdi
	;programa

	; primero verificamos que los indices esten en rango
	
	mov cl, [rdi+ListSize]
	cmp sil, cl
	jge .final
	cmp dl, cl
	jge .final

	mov rdi, [rdi+ListFirst]

	;vemos cual indice es mayor para el loop
	mov cl, sil ; guardamos en CL al actual mayor que es sil entonces el menor es dl
	cmp sil, dl
	jg .loop
	mov cl, dl ;si sil es menor  o igual, entonces ponemos como mayor a dl
	mov dl, sil
	; dejamos r8 para el menor y r9 para el mayorlos casos
	
.loop:

	cmp dl, 0
	jne .seguir
	mov r8, rdi
.seguir:
	dec dl
	cmp cl, 0
	je .fueraLoop
	dec cl
	mov rdi, [rdi+ListElemNext]
	jmp .loop
.fueraLoop:
	mov r9, rdi

	;ahora hacemos swap entre lo que tiene el ListElem que apunta r8 y r9 
	mov rdi, [r8+ListElemData]
	mov rsi, [r9+ListElemData]
	mov [r8+ListElemData], rsi
	mov [r9+ListElemData], rdi


.final:
	
	;desarmamos stackframe
	pop r13
	pop r12
	pop rbp
ret


;------------------------------------------------------

; list_t* listClone(list_t* l)
; l -> rdi

listClone:

	;armamos el stackframe:
    push rbp
    mov rbp, rsp     
    push rbx
    push r12
    push r13
    push r14

	;programa:

    mov rbx, rdi 				;preservamos el puntero a la lista original
    mov rdi, [rbx + ListType]
    call listNew 				;creamos la lista nueva donde sera la copia
    mov r13, rax
    mov r12b, [rbx + ListSize]

    .ciclo:						;vamos iterando los elem de la lista y agregandolos en la nueva (ahi se copian)
    cmp r12b, 0
    je .final
    mov rdi, rbx
    dec r12b
    mov sil, r12b
    call listGet 				;obtenemos el lemento iesimo
    mov rdi, r13
    mov rsi, rax
    call listAddFirst 			;agregamos el elemento copiando
    jmp .ciclo

    .final:
	
    mov rax, r13 				;devolvemos el puntero a la nueva lista clon

	;desarmamos el stackframe
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret



;------------------------------------------------------

	listDelete:

	;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
	;programa
	; nos fijamos si no es vacia
	cmp byte [rdi+ListSize], 0
	mov rbx, rdi
	je .final
	;si no lo es:
	mov r12, [rdi+ListFirst]
	mov r13b, [rdi+ListSize]

	mov edi, [rbx+ListType]
	call getDeleteFunction
	mov r14, rax


	.loop:
	mov rdi, [r12+ListElemData]
	call r14

	mov rdi, r12
	mov r12, [r12+ListElemNext]
	call free

	dec r13b


	cmp r13b, 0
	jne .loop
	
	
.final:

	mov rdi, rbx
	call free

	;desarmamos stackframe
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp 
ret

;--------------------------------------------------------------------------------------------------------------


; ** Card **
; typedef struct s_card { 	|| 0
; char*	suit;				|| 8 bytes -> 0 a 8	
; int32_t* number;			|| 8 bytes  -> 8 a 16
; list_t* stacked;			|| 8 bytes  -> 16 a 24
; } card_t;					|| 24

;------------------------------------------------------

; card_t* cardNew(char* suit, int32_t* number)
; suit -> rdi
; number -> rsi
cardNew:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
	;programa
	mov rbx, rdi
	mov r12, rsi

	mov edi, 24
	call malloc
	mov r13, rax ; aca tenemos el puntero a la nueva carta

	mov rdi, rbx  				; comenzamos a clonar el palo
	call strClone
		
	mov [r13+CardSuit], rax ; guardamos la copia del palo

	mov rdi, r12				; comenzamos a clonar el numero
	call intClone
	
	mov [r13+CardNumber], rax	; guardamos el numero

	mov edi, 3	;comenzamos a crear lista nueva
	call listNew

	mov [r13+CardStacked], rax ; guardamos la lista nueva 

	mov rax, r13


	;desarmamos stackframe
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp 
ret

;------------------------------------------------------

; char* cardGetSuit(card_t* c)
; c->rdi
cardGetSuit:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	;programa
	mov rax, [rdi+CardSuit]
	
	;desarmamos stackframe
	pop rbp 
ret

;------------------------------------------------------

; int32_t* cardGetNumber(card_t* c) 
; c->rdi
cardGetNumber:
	;armamos el stackframe
	push rbp
	mov rbp,rsp
	;programa
	mov rax, [rdi+CardNumber]
	;desarmamos stackframe
	pop rbp 
ret

;------------------------------------------------------

; list_t* cardGetStacked(card_t* c)
; c->rdi
cardGetStacked:
	;armamos el stackframe
	push rbp
	mov rbp,rsp
	;programa
	mov rax, [rdi+CardStacked]
	
	;desarmamos stackframe
	pop rbp 
ret

;------------------------------------------------------

; int32_t cardCmp(card_t* a, card_t* b)
; a -> rdi
; b -> rsi
cardCmp:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	;programa
	mov rbx, rdi
	mov r12, rsi
	mov rdi, [rbx+CardSuit]
	mov rsi, [r12+CardSuit]
	call strCmp
	cmp eax, 0

	jne .final
	
	mov rdi, [rbx+CardNumber]
	mov rsi, [r12+CardNumber]
	call intCmp
	


	.final:
	
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp 
ret

;------------------------------------------------------

; card_t* cardClone(card_t* c)
; c -> rdi
cardClone:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	;programa
	mov rbx, rdi
	mov rdi, [rbx+CardSuit]	;comenzamos a crear la nueva carta para la copia
	mov rsi, [rbx+CardNumber]
	call cardNew	;tenemos la carta copiada en rax
	
	mov r12, rax
	;recordar hacer delete de la lista vacia
	mov rdi, [r12+CardStacked]
	call listDelete

	;comenzamos con la copia de la lista
	mov rdi, [rbx+CardStacked]
	call listClone	; ahora tenemos en rax la copia del stack
	
	mov [r12+CardStacked], rax 

	mov rax, r12  ; guardamos el puntero a devolver
	
	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp 
ret

;------------------------------------------------------

; void cardAddStacked(card_t* c, card_t* card)
; c -> rdi
; card -> rsi
cardAddStacked:
;armamos el stackframe
	push rbp
	mov rbp,rsp

	;programa
	mov rdi, [rdi+CardStacked]
	call listAddFirst

	;desarmamos stackframe
	pop rbp 
ret

;------------------------------------------------------

; void cardDelete(card_t* c)
; c -> rdi
cardDelete:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	;programa
	mov rbx, rdi ; preservamos rdi

	; primero borramos el suit con strDelete
	mov rdi, [rbx+CardSuit]
	call strDelete
	
	; borramos el numero con intDelete
	mov rdi, [rbx+CardNumber]
	call intDelete

	; borramos el stack con listDelete

	mov rdi, [rbx+CardStacked]
	call listDelete
	
	; borramos la str de la carta llamando a free
	mov rdi, rbx
	call free

	;Desarmamos stackframe
	pop r12
	pop rbx
	pop rbp 
ret

;------------------------------------------------------

; void cardPrint(card_t* c, FILE* pFile)
; c -> rdi
; pFile -> rsi
cardPrint:
;armamos el stackframe
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	;programa

	mov rbx, rdi	; preservamos los punteros
	mov r12, rsi

	mov rdi, corcheteOpen	;imprimimos corchete para iniciar carta
	call strPrint
	
	mov rdi, [rbx+CardSuit]	;imprimimos el suit
	mov rsi, r12
	call strPrint
	
	mov rdi, guion		;imprimimos primer guion
	mov rsi, r12
	call strPrint
	
	mov rdi, [rbx+CardNumber] ;imprimos el numero
	mov rsi, r12
	call intPrint

	mov rdi, guion ;imprimimos segundo guion
	mov rsi, r12
	call strPrint
	
	mov rdi, [rbx+CardStacked] ;imprimimos stack
	mov rsi, r12
	call listPrint
	
	mov rdi, corcheteClose	;imprimimos corchete para cerrar la carta
	mov rsi, r12
	call strPrint

	;desarmamos stackframe
	pop r12
	pop rbx
	pop rbp 
ret

