;-------------------------------------------------------
; STREET FIGHTER LEVEL SCROLLER

; Create a batch of screen-printing routines, then use them to quickly blit back the Street Fighter background screens.

;-------------------------------------------------------
; Entry point
				dump 1,0
				; autoexec								; Include this line to create auto-running code from pyZ80
				org &8000

auto.start:
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
; MODULES
				include "house.asm"						; Housekeeping routines
				include "compile equates.asm"			; Equates for compiling code/self-modifying code
				include "create.asm"					; Compile routines
				include "display.asm"					; Display routines

;-------------------------------------------------------
main.scroll_os:		dw 512								; Scroll offset in bytes - only 
main.scroll_dir:	db 0								; Current direction of scroll
main.scr_page1:		db ScreenPage
main.scr_page2:		db ScreenPage2

;-------------------------------------------------------
; MAIN LOOP
main.start:
				ld a,(&8000 - 1)
				cp -1
				jp z,main.print
				cp 1
				jp z,main.load1
				cp 2
				jp z,main.load2
				cp 3
				jp z,main.load3

main.demo:
				in a,(LMPR)
				and %00011111
				out (LMPR),a
				ld a,(main.scr_page1)
				or Mode4
				out (VMPR),a

				call main.set_palette

@create_spans:											; Create compile code gfx page by gfx page
				call main.load1
				call main.load2
				call main.load3

				ld a,(main.scr_page1)					; This effect runs on one page only
				or ROMout
				out (LMPR),a
@print:
				in a,(KeyboardReg)						; Pause if space pressed
				cp 95
				jr nz,@-print

				call main.swap_screens

				ld a,(main.scroll_dir)
				or a
				jr nz,@+back
	@forward:
				ld hl,(main.scroll_os)
				for 4, dec hl
				ld (main.scroll_os),hl
				ld bc,128								; Scroll offset bounces between 128 and 512 (maps are 2.5 screens wide)
				sbc hl,bc
				ld a,h
				or l
				or a
				jr nz,@+next
				ld a,1
				ld (main.scroll_dir),a
				jp @+next
	@back:
				ld hl,(main.scroll_os)
				for 4, inc hl
				ld (main.scroll_os),hl
				ld bc,512
				sbc hl,bc
				ld a,h
				or l
				or a
				jr nz,@+next
				xor a
				ld (main.scroll_dir),a
		@next:
				call main.print
				jp @-print

;-------------------------------------------------------
main.print1:
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
				ret

main.print2:
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
				ret
				
;-------------------------------------------------------
main.load1:
				ld a,GfxPage ;(main.scr_page1)
				ld b,a
				ld c,0
				call create.comp_scrBC
				ret

main.load2:
				ld a,GfxPage2 ;(main.scr_page1)
				ld b,a
				ld c,1
				call create.comp_scrBC
				ret

main.load3:
				ld a,GfxPage3 ;(main.scr_page1)
				ld b,a
				ld c,2
				call create.comp_scrBC
				call display.install					; Install display print manager under both screens
				ret

;-------------------------------------------------------
; main.clear_screen:
	; @paging:
				; in a,(LMPR)
				; ld ( @+rest_lo + 1),a
				; ld a,(main.scr_page1)
				; or ROMOut
				; out (LMPR),a

				; ld hl,0
				; ld de,1
				; ld bc,&6000 - 1
				; ld (hl),0
				; ldir

	; @paging:
		; @rest_lo: ld a,0
				; out (LMPR),a
				; ret

;-------------------------------------------------------
main.set_palette:
				ld hl,main.palette + 15
				ld bc,4344
				otdr
				ret

main.palette:	db 0,9,12,2,7,15,74,90,83,36,39,98,103,112,122,255

;-------------------------------------------------------
main.swap_screens:
	@scr:		ld a,0
				xor 1
				ld ( @-scr + 1),a
				or a
				jp z,@+scr_2

	@scr_1:
				ld a,(main.scr_page1)
				or ROMOut
				out (LMPR),a
				ld a,(main.scr_page2)
				or Mode4
				out (VMPR),a
				ret

	@scr_2:
				ld a,(main.scr_page2)
				or ROMOut
				out (LMPR),a
				ld a,(main.scr_page1)
				or Mode4
				out (VMPR),a
				ret

;-------------------------------------------------------

;=======================================================
auto.end:
auto.len:		equ auto.end - auto.start

print "-----------------------------------------------------------------------------------"
print "auto.start      ", auto.start, 		" auto.end   ", auto.end, 		" auto.len    ", auto.len
print "jump.start      ", jump.start, 		" jump.end   ", jump.end, 		" jump.len    ", jump.len
print "int.start       ", int.start, 		" int.end    ", int.end, 		" int.len     ", int.len
print "gfx.start       ", gfx.start, 		" gfx.end    ", gfx.end, 		" gfx.len     ", gfx.len
print "-----------------------------------------------------------------------------------"
