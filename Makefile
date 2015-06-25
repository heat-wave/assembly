ASM = yasm
ASFLAGS = -f elf64 -gdwarf2

CFLAGS = -g -Wall
CC = g++

EXECUTABLE = main
LIBIMG = libimg

all: $(EXECUTABLE)

clean:
	rm -f $(LIBIMG).o
	rm -f $(LIBIMG).a
	rm -f $(EXECUTABLE).o
	rm -f $(EXECUTABLE)

$(EXECUTABLE): $(LIBIMG).a $(EXECUTABLE).o
	$(CC) $(CFLAGS) $(EXECUTABLE).cpp $(LIBIMG).a -o $@

$(EXECUTABLE).o:
	$(CC) $(CFLAGS) -c $(EXECUTABLE).cpp -o $@

$(LIBIMG).a: image.o matrix.o
	ar rcs $@ image.o matrix.o

matrix.o: matrix.asm
	$(ASM) $(ASFLAGS) -o $@ $<

image.o: image.asm
	$(ASM) $(ASFLAGS) -o $@ $<