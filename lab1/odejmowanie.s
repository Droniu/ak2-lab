# stale uzywane przy zakonczeniu programu
SYSEXIT = 1
EXIT_SUCCESS = 0

# sekcja .data z liczbami, ktore dodajemy
.data
liczba1:
	.long 0x10304008, 0x701100FF, 0x45100020, 0x08570030
liczba2:
	.long 0xF040500C, 0x00220026, 0xF21000CB, 0x04520031

liczba1_len = . - liczba1

.text
.globl _start
_start:
	# wyzerowanie rejestrow oraz flagi carry
	xor %eax, %eax
	xor %ebx, %ebx
	xor %ecx, %ecx
	xor %edx, %edx
	clc

	# obliczamy ile liczb 4-bajtowych w tablicy	
	mov $4, %ecx
	mov $liczba1_len, %eax
	div %ecx
	mov %eax, %ecx

dekrementacja:	
	dec %ecx
	# pobieramy kolejne wartosci liczac od konca
	mov liczba1(,%ecx,4), %eax
	mov liczba2(,%ecx,4), %ebx
	sbb %ebx, %eax
	push %eax

	# jesli ecx pusty, konczymy	
	jecxz koniec
	jmp dekrementacja

koniec:	
	jnc wyjscie
	# jesli wystapilo przeniesienie (carry) zaznaczamy to
	# przekazujac jedynke na stos.
	# w przeciwnym wypadku od razu przechodimy do wyjscia
	push $0x00000001

wyjscie:	
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
