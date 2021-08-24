;-------------------------------------------------------
; CREATE ROUTINES

;-------------------------------------------------------
create.buffer:	ds &80									; Buffer for input data (grab data without header)
create.output:	ds &100									; Buffer for compiled code
create.pos:		dw create.buffer + &80 
create.line:	db 0									; Raster line currently being created

;-------------------------------------------------------
create.comp_scrBC:
; Make and store spans for screen at page B, screen C (0-2)
				ld a,b
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
				cp 40
				jp c,@+next
				sub 40
				inc b
				inc b
				jp @-loop
		@next:
				ld d,a

	@paging:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,b
				or ROMOut
				out (LMPR),a
				
				ld a,d
				add a
				add d
				add 2
				sub c
				ld d,a
				ld e,0
				ld hl,create.output
				ld bc,&100
				ldir
				
	@paging:
		@rest_lo: ld a,0
				out (LMPR),a
				ret

;-------------------------------------------------------
; SOURCE GRAPHICS 

; This will eventually be left to Gord to load in from BASIC

create.src:
				dump GfxPage,0
				mdat "ken1.raw"
				
				dump GfxPage2,0
				mdat "ken2.raw"
				
				dump GfxPage3,0
				mdat "ken3.raw"
				
				dump MainPage,create.src - &8000
				org create.src

				db 0
;-------------------------------------------------------
