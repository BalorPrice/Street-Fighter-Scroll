;-------------------------------------------------------
; CREATE ROUTINES

; Create long routines capable of printing three screens wide horizontal graphics by using repeats of LD DE,nn; PUSH DE
; Display programs then self-modify exit points and jump in at correct point.
; There are about 9 16K pages used for the compiled code, not really practical for a real game!

;-------------------------------------------------------
create.buffer:	ds &80									; Buffer for input data, in grab data format without header
create.output:	ds &100									; Buffer for compiled code
create.pos:		dw create.buffer + &80 					; Pointer to source data
create.line:	db 0									; Raster line currently being created

;-------------------------------------------------------
create.comp_scrC:
; Make and store spans for screen 1, map screen C (0-2)
				ld a,(main.scr_page1)
				ld ( @+page_scr1 + 1),a
				ld a,c
				ld ( @+page_scr2 + 1),a
				
				xor a
	@loop:
				push af

				push af
		@page_scr1: ld b,0
				call create.load_bufferAB				; Fill buffer for compilation from screen data
				call create.span						; Make compile code, deposit in create.output buffer
				pop af
		@page_scr2: ld c,0
				call create.store_bufferAC				; Store line in main compiled code pages
				
				pop af
				inc a
				cp 192
				jr nz,@-loop
				ret
				
;-------------------------------------------------------
create.load_bufferAB:
; Fill buffer from screen. 256 pixels from line A of screen at page B
	@get_src_addr:										; Calc line * 128 to get offset for source
				ld h,a
				ld l,0
				srl h
				rr l
				ld de,create.buffer
	@paging:											; Page source gfx into low mem
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,b
				or ROMOut
				out (LMPR),a
	@move_data:
				ld bc,&80
				ldir
	@paging:
		@rest_lo: ld a,0
				out (LMPR),a
				ret

;-------------------------------------------------------
create.span:
; Make span code from buffer data
	@paging:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,(main.scr_page1)
				or ROMOut
				out (LMPR),a
				
				ld de,(create.pos)						; DE=> end of buffer to compile
				ld hl,create.output						; HL=> position of compilation (one-pass will do)
				ld b,64
	@loop:
				push bc
				call @+compile_4pix
				pop bc
				djnz @-loop
				
	@paging:
		@rest_lo: ld a,0
				out (LMPR),a
				ret

@compile_4pix:
				ld (hl),ld_de.nn						; Store LD DE,nnnn
				inc hl
				
				dec de									; Collect data
				ld a,(de)
				ld b,a
				dec de
				ld a,(de)
				
				ld (hl),a								; Store data in little-endian
				inc hl
				ld (hl),b
				inc hl
				
				ld (hl),push_de							; Store PUSH DE
				inc hl
				ret

;-------------------------------------------------------
create.store_bufferAC:
; Store span in buffer to routine A, screen C.
	@find_comp_page:									; Find page to store compile code into
				ld b,CompPage
		@loop:
				cp 40									; Each page pair stores 40 lines of compiled code, with a little gap.
				jp c,@+next
				sub 40
				inc b
				inc b
				jp @-loop
		@next:
				ld d,a									; Keep A MOD 40 for offset into page

	@paging:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,b
				or ROMOut
				out (LMPR),a
				
				ld a,d									; This will be MSB of address.  Multiply by 3 (768 bytes per pixel row)
				add a
				add d
				add 2									; As compiled code prints backwards, do 2-C to get map screen offset
				sub c
				ld d,a
				ld e,0
				ld hl,create.output						; Move buffer to destination
				ld bc,&100
				ldir
				
	@paging:
		@rest_lo: ld a,0
				out (LMPR),a
				ret

;-------------------------------------------------------
