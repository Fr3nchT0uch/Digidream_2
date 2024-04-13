# WOZ "CATALOG"    			MEMORY  MAP / RAM TYPE / COMP -> DEST
# boot0:    	T00/S00			$0800	    MAIN
# FLOAD:		T00/S01-T00/S0x $FC00	   RAMCARD
# MAIN:  		T01/S00-T01/Sxx	$D000	   RAMCARD		
# MUSIC:		T02/S00-T04/SXX	$1000	    MAIN      *   -> $1000 (AUX)
# HGR			T05/S00-T06/S31 $2000		MAIN
# DGR			T07/S00-T07/S31 $800		M/A
# EFFECT		T08/S00-TXX/SXX $6000		MAIN

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


$(DISK): floadc.b BOOT effect.b main.b

	$(GENWOZ)  -t "0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"

# boot.b
	$(W2W) s p 0 0 $(DISK) boot.b

# floadc.b 		T0 S1	> $FC00 (LC)
	$(W2W) s p 0 1 $(DISK) floadc.b
# main.b 		T1 S0 	> $D000 (LC)
	$(W2W) c p 1 0 $(DISK) main.b
# music			T2 S0	> $1000 (M) * >> $1000 (A)
	$(W2W) c p 2 0 $(DISK) music\ZIC.lz4
# HGR			T5 S0	> $2000
	$(W2W) c p 5 0 $(DISK) hgr\PI.STEP10
# DGR			T7 S0 	> $800M | T7 S16 > $800A
	$(W2W) c p 7 0 $(DISK) dgr\1.main
	$(W2W) c p 7 16 $(DISK) dgr\1.aux
# EFFECT		T8 S0	> $6000
	$(W2W) c p 8 0 $(DISK) effect.b


# launching EMULATOR / copy SYM file for AW
	copy lbl_main.txt $(APPLEWINPATH)\A2_USER1.SYM
	$(EMULATOR) $(DISK)

BOOT:
	$(ACME) boot.b boot.a

floadc.b: floadc.a
	$(ACME) floadc.b floadc.a

effect.b: effect.a
	$(ACME) effect.b effect.a

main.b: main.a floadc.a effect.a
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
