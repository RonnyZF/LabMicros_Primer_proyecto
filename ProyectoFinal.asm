
%include "linux64.inc"

section .data
	Memoria db "/proc/meminfo",0 					;Dirección del archivo de memoria
	CPU_info db "/proc/cpuinfo",0					;Dirección del archivo de cpuinfo
	stat_info db "/proc/stat",0					;Dirección del archivo de procesos del procesador
	mem_text db 10,"Datos Memoria RAM",10,0				; Texto a mostrar
	CPU_text  db "Datos informacion Procesador",0			; Texto a mostrar
	CPU_process_text db 10,"Datos seguimiento Procesador",10,0		; Texto a mostrar
	Process db 10,"-------Seguimiento procesador------------",10,0
  tamano: db 10
  linea_dos: db '10',0xa	
  l2_tamano: equ $-linea_dos
  
  timeval:
  tv_sec  dd 0
  tv_usec dd 0

  answer:
  db      "%d", 10, 0

  nargerror:
  db      "Se requiere un argumento", 10, 0

  bargerror:
  db      "El argumento no puede ser negativo", 10, 0

section .bss
	text_mem resb 100						; Buffer puntero del archivo donde se almacena la informacion cargada
	text_cpu_inf resb 100						;Buffer puntero del archivo de carga de datos
	text_stat resb 100						;Buffer puntero del archivo de carga de datos

global  main
extern  atoi
extern puts
        section .text
main:
        push    r12                     ; se guardan los registros temporales en la pila
        push    r13

        cmp     rdi, 2                  ; Debe haber un solo argumento
        jne     error1

        mov     r12, rsi                ; puntero argv

        mov     rdi, [r12+8]           ; rdi=argv[1]
        call    atoi                    ; eax=atoi(argv[1])
        cmp     eax, 0                  ; No debe ser negativo
        jl      error2
        mov     r13, rax               ; r13=eax=atoi(argv[1])
        
	print CPU_text							; Imprime texto
	int 0x80							; Interrupcion del sistema
	call cpu_vend							; llama funcion del codigo
	int 0x80
	call cpu_mod
	int 0x80
	call cpu_frec
	int 0x80
	call cpu_cache
	int 0x80
	call cpu_core
	int 0x80
	print mem_text
	call memT
	int 0x80
loop:
  	dec r13
  	push r13 ; guarda r13 en caso de que se use. La pila debe estar balanceada 
  	;código
	print Process
	int 0x80
	print mem_text
	int 0x80
	call memF
	int 0x80
	print CPU_process_text
	call stat_CPU
	int 0x80
  	call sleep

  	;código
  	pop r13 ; retorna el valor a r13
  	cmp r13, 0
  	jne loop

        jmp Fin
error1:                                 ; argumento negativo
        mov     edi, nargerror
        call    puts
        jmp     Fin
error2:                                 ; Más o menos de un argumento
        mov     edi, bargerror
        call    puts
Fin:
  pop     r13
  pop     r12
  mov   rax, 1
  int 0x80

imprime:
  mov   rax, 1
  mov   rdi, 1
  mov   rsi, linea_dos
  mov   rdx, l2_tamano
  syscall
  ret
sleep:
  mov dword [tv_sec], 1
  mov dword [tv_usec], 0
  mov eax, 162
  mov ebx, timeval
  mov ecx, 0
  int 0x80
  ret



	
memT:									;Función llamada 

									; Apertura de archivo

	mov rax, SYS_OPEN						;Funcion de apertura del archivo
	mov rdi, Memoria						;Direccion del archivo
	mov rsi, O_RDONLY 
	mov rdx, 0
	syscall								; Llamada del sistema

									;Inicio de Lectura de datos

	push rax							; Puesta en pila
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_mem						; Lugar de almacenamiento de lectura
	mov rdx, 26 							; limite superior de bits a imprimir
	syscall

									;cierre del archivo

	mov rax, SYS_CLOSE						;instruccion de cierre
	pop rdi								;saca de la pila rdi
	syscall

	mov edx, text_mem
	print text_mem	
	ret								;retorna
memF:
	mov rax, SYS_OPEN
	mov rdi, Memoria
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_mem
	mov rdx, 56 
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_mem
	print text_mem+28
	ret

cpu_vend:
	mov rax, SYS_OPEN
	mov rdi, CPU_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_cpu_inf
	mov rdx, 38
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_cpu_inf
	print text_cpu_inf+13
	ret

cpu_mod:
	mov rax, SYS_OPEN
	mov rdi, CPU_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_cpu_inf
	mov rdx, 107
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_cpu_inf
	print text_cpu_inf+66
	ret

cpu_frec:
	mov rax, SYS_OPEN
	mov rdi, CPU_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_cpu_inf
	mov rdx, 155
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_cpu_inf
	print text_cpu_inf+133
	ret

cpu_cache:
	mov rax, SYS_OPEN
	mov rdi, CPU_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_cpu_inf
	mov rdx, 175
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_cpu_inf
	print text_cpu_inf+155
	ret

cpu_core:
	mov rax, SYS_OPEN
	mov rdi, CPU_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_cpu_inf
	mov rdx, 232
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_cpu_inf
	print text_cpu_inf+217
	ret

stat_in:
	mov rax, SYS_OPEN
	mov rdi, stat_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_stat
	mov rdx, 10000
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_stat
	print text_stat
	ret

stat_CPU:
	mov rax, SYS_OPEN
	mov rdi, stat_info
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall

	push rax
	mov rdi, rax
	mov rax, SYS_READ
	mov rsi, text_stat
	mov rdx, 218
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall

	mov edx, text_stat
	print text_stat+87
	ret	

