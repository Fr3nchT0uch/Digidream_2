# WOZ "CATALOG"    			MEMORY  MAP / RAM TYPE / COMP -> DEST
# boot0:    	T00/S00			$0800	    MAIN
# FLOAD:		T00/S01-T00/S0x $FC00	   RAMCARD
# MAIN:  		T01/S00-T01/Sxx	$D000	   RAMCARD		
# MUSIC:		T02/S00-T02/SXX	$1000	     MAIN     *   -> $1000 (AUX)

### TOOLS
PYTHON3 = C:\Python3\python.exe
ACME = acme.exe -f plain -o
LZ4 = lz4.exe
ZPACK = zpacker.exe
DSK2WOZ = DSK2WOZ.exe
W2W = W2W.exe
GENWOZ = GENWOZ.exe
BIN2DISK = $(PYTHON3) bin2disk.py
DIRECTWRITE = $(PYTHON3) $(A2SDK)\bin\dw.py
INSERTBIN = $(PYTHON3) $(A2SDK)\bin\InsertBIN.py
TRANSAIR = $(PYTHON3) $(A2SDK)\bin\transair3.py
GENDSK = $(PYTHON3) $(A2SDK)\bin\genDSK.py
COPYFILES = $(PYTHON3) $(A2SDK)\bin\InsertZIC.py

### EMULATORS
APPLEWINPATH = C:\Progx86\AppleWin
APPLEWIN = $(APPLEWINPATH)\Applewin.exe -d1
AIPC = C:\Progx86\Aipc
MAME = $(A2SDK)\Mame

EMULATOR = $(APPLEWIN)

### TARGET
DISK = test.woz

### BUILD
all: $(DISK)


$(DISK): floadc.b BOOT main.b

	$(GENWOZ)  -t "0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"

# boot.b
	$(W2W) s p 0 0 $(DISK) boot.b

# floadc.b 		T0 S1	> $FC00 (LC)
	$(W2W) s p 0 1 $(DISK) floadc.b
# main.b 		T1 S0 	> $D000 (LC)
	$(W2W) c p 1 0 $(DISK) main.b
# music		T2 S0	> $1000 (M) * >> $1000 (A)
	$(W2W) c p 2 0 $(DISK) music\ZIC.lz4

# launching EMULATOR / copy SYM file for AW
	copy lbl_main.txt $(APPLEWINPATH)\A2_USER1.SYM
	$(EMULATOR) $(DISK)

BOOT:
	$(ACME) boot.b boot.a

floadc.b: floadc.a
	$(ACME) floadc.b floadc.a

main.b: main.a floadc.a
	$(ACME) main.b main.a


clean:
	del *.b
	del lbl_*.txt




### VSC ACTION BUTTONS SETUP ### not necessary for everyone !!!
AW_PAL:
	$(APPLEWIN) $(DISK) -50hz

AW_NTSC:
	$(APPLEWIN) $(DISK) -60hz
	
MAME:
## APPLE IIE 50HZ (UK) + MCK SLOT4 (default)
	$(MAME)\mame.exe -skip_gameinfo -window -resolution0 800x800 -rompath $(MAME)\roms apple2euk -flop1 $(DISK)

## APPLE IIE 50HZ (UK) + MCK SLOT4 (default) + DEBUG
###	$(MAME)\mame.exe -skip_gameinfo -window -resolution0 800x800 -debug -debugger_font_size 12 -rompath $(MAME)\roms apple2euk -flop1 $(DISK)
