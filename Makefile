# MPLAB IDE generated this makefile for use with GNU make.
# Project: pecera.mcp
# Date: Thu Jul 18 19:38:07 2013

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

pecera.cof : pecera.o
	$(CC) /p16F84A "pecera.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"pecera.cof" /M"pecera.map" /W

pecera.o : pecera.asm ../../../../Archivos\ de\ programa/Microchip/MPASM\ Suite/p16f84.inc
	$(AS) /q /p16F84A "pecera.asm" /l"pecera.lst" /e"pecera.err" /o"pecera.o" /d__DEBUG=1

clean : 
	$(CC) "pecera.o" "pecera.err" "pecera.lst" "pecera.cof" "pecera.hex"

