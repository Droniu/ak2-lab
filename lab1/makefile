all: dodawanie odejmowanie

dodawanie.o: dodawanie.s
	as --32 --gstabs+ dodawanie.s -o dodawanie.o
dodawanie: dodawanie.o
	ld -m elf_i386 dodawanie.o -o dodawanie

odejmowanie.o: odejmowanie.s
	as --32 --gstabs+ odejmowanie.s -o odejmowanie.o
odejmowanie: odejmowanie.o
	ld -m elf_i386 odejmowanie.o -o odejmowanie

