;-------------------------------------------------------
; HOUSEKEEPING ROUTINES

; Paging
MainPage:		equ 1									; Code here
GfxPage:		equ 4									; Input graphics load here in demo mode
GfxPage2:		equ 6
GfxPage3:		equ 8
CompPage:		equ 10									; Pages used for the compiled code used to print the screens
CompPage2:		equ 12
CompPage3:		equ 14
CompPage4:		equ 16
CompPage5:		equ 18
ScreenPage:		equ 20 									; Display page
ScreenPage2:	equ 22

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
