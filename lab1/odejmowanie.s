# Odejmowanie dziala tak samo jak dodawanie, przy czym uzywamy sbbl zamiast adcl

# stale uzywane przy zakonczeniu programu
SYSEXIT = 1
EXIT_SUCCESS = 0

# sekcja .data z liczbami, ktore dodajemy
.data
l1: 
    .long 0x10304008, 0x701100FF, 0x45100020, 0x08570030 
l1_len = (. - l1)/4 # dlugosc pierwszej liczby

l2:
    .long 0xF040500C, 0x00220026, 0x321000CB, 0x04520031 
l2_len = (. - l2)/4 # dlugosc drugiej liczby

.text
.globl _start
_start:
	# wyzerowanie rejestrow oraz flagi carry
	xor %eax, %eax
	xor %ebx, %ebx
	xor %edi, %edi
	xor %esi, %esi
	clc
	pushf  # push rejestru eflags na stos

	movl $l1_len, %edi  # ustawienie licznika petli (edi) dla pierwszej liczby
	dec %edi # dekrementacja licznika petli dla pierwszej liczby

	# analogicznie dla drugiej liczby - uzywamy esi
	movl $l2_len, %esi
	dec %esi 

add:
	popf # polecenie odwrotne do pushf - zaladowanie eflags ze stosu

	# odejmowanie wykonujemy na akumulatorze (eax) oraz ebx, tak więc tam wkladamy
	# kolejne fragmenty danych liczb, na ktore wskazuja rejestry edi i esi

	movl l1(,%edi, 4), %eax 
	movl l2(,%esi, 4), %ebx

	# faktyczne odejmowanie (wynik w akumulatorze)
	sbbl %ebx, %eax
	
	# wynik i eflags na stos
	push %eax 
	pushf

	# dekrementacja esi i edi, aby odejmowac kolejny fragment liczby
	dec %edi #dekrementacja licznika liczby1
	dec %esi #dekrementacja licznika liczby2

	# cmp + jl/jge/jle/jg sluza do warunkowych jumpow,
	# w tym przypadku cmp + jg oznacza "jump if less".
	# jesli esi jest ujemne to wartosc ta bedzie wlasciwa,
	# czyli jump sie wykona. sprawdzamy w ten sposob oba rejestry.
	# Sytuacja ma miejsce gdy jedna z liczb bedzie krotsza od drugiej.
	cmp $0,%esi 
	jl add_edi
	cmp $0,%edi
	jl add_esi

	# jesli wszystko jest w porzadku wykonujemy znowu add.
	jmp add 


# zarowno w edi i esi sprawdzamy czy nie skonczyly sie obie liczby, wtedy przechodzimy na koniec.
add_edi:
	cmp $0,%edi
	jl koniec_carry
	
	movl l1(,%edi, 4), %eax
	popf
	
	# odejmowanie zera, reszta dzieje sie analogicznie
	sbbl $0, %eax
	push %eax 
	dec %edi #
	pushf
	jmp add_edi

add_esi:
	cmp $0,%esi 
	jl koniec_carry
	
	movl l2(,%esi, 4), %eax #wpisanie do rejestru eax wycietej liczby z l1 o dlugosci 4 o okrelsonym indeksie
	popf

	# odejmowanie zera, reszta dzieje sie analogicznie
	sbbl $0, %eax
	push %eax
	dec %esi
	pushf
	jmp add_esi

koniec:	
	popf
	jnc wyjscie
	# jesli wystapila pozyczka (borrow) zaznaczamy to
	# przekazujac jedynke na stos.
	# w przeciwnym wypadku od razu przechodimy do wyjscia
	push $0x00000001

wyjscie:	
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
