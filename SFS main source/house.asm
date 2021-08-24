;-------------------------------------------------------
; HOUSEKEEPING ROUTINES

; Paging
MainPage:		equ 1									; Code here
CompPage:		equ 4 									; Pages used for the compiled code used to print the screens
CompPage2:		equ 6
CompPage3:		equ 8
CompPage4:		equ 10
CompPage5:		equ 12

; Hardware values
LMPR:			equ 250
HMPR:			equ 251
VMPR:			equ 252
PaletteBaseReg:	equ 248
StatusReg:		equ 249
FrameIntBit:	equ 3
KeyboardReg:	equ 254
BorderReg:		equ 254
ROMOut:			equ %00100000
Mode4:			equ 32 * 3

;-------------------------------------------------------
