;-------------------------------------------------------
; STREET FIGHTER LEVEL SCROLLER, by tobermory@cookingcircle.co.uk, 24 August 2021.

; Create a batch of screen-printing routines, then use them to quickly blit back the Street Fighter background screens.
; This version intended to be used with a Basic program, see instructions.txt for 

;-------------------------------------------------------
; Entry point
				dump 1,0
				org &8000

				di
	@set_stack:
				ld ( @+rest_stack + 1),sp
				ld sp,@+stack

				call main.start

	@rest_stack: ld sp,0
				ei
				ret

				ds &40
@stack:

;-------------------------------------------------------
main.control:		db 0								; Control byte
main.scroll_os:		dw 512								; Scroll offset in bytes, bottom 2 bits ignored.
main.scr_page1:		db 0								; Page of screen 1
main.scr_page2:		db 0								; Page of screen 2

;-------------------------------------------------------
; MODULES
				include "house.asm"						; Housekeeping routines
				include "compile equates.asm"			; Equates for compiling code/self-modifying code
				include "create.asm"					; Compile routines
				include "display.asm"					; Display routines

;-------------------------------------------------------
; MAIN LOOP
main.start:
				ld a,(main.control)						; Interpret control byte
				cp -1
				jp z,main.print1						; if -1, print to screen 1
				cp -2
				jp z,main.print2						; -2 for print to screen 2
				cp 1
				jp z,main.load1							; If 1/2/3, create compile span routines for screen 1/2/3
				cp 2
				jp z,main.load2
				cp 3
				jp z,main.load3
				ret

;-------------------------------------------------------
main.print1:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(main.scr_page1)
				and %00011111
				or ROMout
				out (LMPR),a
				
				ld b,CompPage
				ld a,40
				ld ix,&0080
				call display.printIXAB
				ld b,CompPage2
				ld a,40
				ld ix,&1480
				call display.printIXAB
				ld b,CompPage3
				ld a,40
				ld ix,&2880
				call display.printIXAB
				ld b,CompPage4
				ld a,40
				ld ix,&3c80
				call display.printIXAB
				ld b,CompPage5
				ld a,32
				ld ix,&5080
				call display.printIXAB
				
	@rest_lo:	ld a,0
				out (LMPR),a
				ret

main.print2:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(main.scr_page2)
				and %00011111
				or ROMout
				out (LMPR),a
				
				ld b,CompPage
				ld a,40
				ld ix,&0080
				call display.printIXAB
				ld b,CompPage2
				ld a,40
				ld ix,&1480
				call display.printIXAB
				ld b,CompPage3
				ld a,40
				ld ix,&2880
				call display.printIXAB
				ld b,CompPage4
				ld a,40
				ld ix,&3c80
				call display.printIXAB
				ld b,CompPage5
				ld a,32
				ld ix,&5080
				call display.printIXAB
				
	@rest_lo:	ld a,0
				out (LMPR),a
				ret
				
;-------------------------------------------------------
main.load1:
				ld c,0
				call create.comp_scrC
				ret

main.load2:
				ld c,1
				call create.comp_scrC
				ret

main.load3:
				ld c,2
				call create.comp_scrC
				call display.install					; Install display print manager under both screens
				ret

;-------------------------------------------------------
