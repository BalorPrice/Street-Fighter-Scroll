;-------------------------------------------------------
; DISPLAY ROUTINES
				
;-------------------------------------------------------
display.install:
; Install printer management routine under both screens
; You'll need to have both screen pages loaded in before doing this
	@paging:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
	@scr1:
				ld a,(main.scr_page1)
				or ROMOut
				out (LMPR),a
	@copy:
				ld hl,display.src
				ld de,&6000
				ld bc,display.len
				ldir
	@scr2:	
				ld a,(main.scr_page2)
				or ROMOut
				out (LMPR),a
	@copy:
				ld hl,display.src
				ld de,&6000
				ld bc,display.len
				ldir
	@paging:	
	@rest_lo:	ld a,0
				out (LMPR),a
				ret
				
;-------------------------------------------------------
display.src:

;=======================================================
				org &6000
display.printIXAB:
; Print all the lines of the screen in order
; IX = start position for stack (one line down from start address)
; A = depth in lines to print
; B = Page of span routines to use
				ld hl,(main.scroll_os)					; Preserve offset, memory is paged out and registers are swapped
				res 0,l
				res 1,l
				ld ( @+offset + 1),hl
@paging:
				ex af,af'
				ld ( @+rest_sp + 1),sp					; Preserve stack, only used for printing
				in a,(HMPR)								; Page compiled routines into high memory
				ld ( @+rest_hi + 1),a
				ld a,b
				out (HMPR),a
				ex af,af'
				
				ld hl,@+return							; Set return address for span printers to jump back to
				exx
				ld bc,&80								; Update to get to next line down for SP
				
	@offset:	ld de,0
				ld iy,&8000								; Start address for span printer
				add iy,de
				ld hl,&8100								; Return address for span printers
				add hl,de
				
@loop:
				ld (hl),jp_hl							; Set end point in routine (overwrite a LD DE,nn instruction)
				ld sp,ix								; Set start stack position
				exx
				jp (iy)									; Jump into compiled routine, jumps back with jp (hl) instruction inserted
	@return:
				exx
				ld (hl),ld_de.nn						; Restore overwritten byte in span routine
				
				inc iyh									; Find next span printer addresses
				inc iyh
				inc iyh
				inc h
				inc h
				inc h
				
				add ix,bc								; Next line down for stack
				
				dec a
				jp nz,@-loop

@paging:
	@rest_sp:	ld sp,0
	@rest_hi:	ld a,0
				out (HMPR),a
				ret
				
;-------------------------------------------------------
				
display.end:
;=======================================================
display.len:	equ display.end - display.printIXAB
				org display.src + display.len

;-------------------------------------------------------
