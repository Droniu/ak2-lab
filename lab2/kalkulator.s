SYSEXIT = 1


EXIT_SUCCESS = 0

.data
control: .word 0b0110000111111

# za wybor zaokraglenia odpowiada 10 i 11 bit 
# 0x03F najblizsze
# 0x43F dol
# 0x83F gora
# 0xC3F obciecie


floatA: .float 4.45622
floatB: .float 0.99237

doubleA: .double 0.12333033
doubleB: .double -2.0123552

.text
.global _start

_start:

    # ladowanie control worda do FPU
    fldcw control   
    jmp _operacje    

_loadf:
    # ladowanie liczb
    flds floatA
    flds floatB
    ret

_loadd:
    fldl doubleA
    fldl doubleB
    ret

_operacje:
    call _loadd
    faddp # A+B
    
    call _loadd
    fsubp # A-B
    
    call _loadd
    fmulp # A*B
    
    call _loadd
    fdivp # A/B

_exit:
	movl $SYSEXIT, %eax
	movl $EXIT_SUCCESS, %ebx
	int $0x80	

