; I BELIEVE I TOOK ALL THE DOCUMENTATION COMMENTS FROM THE YOSHI DOCUMENT

; PPUADDR	$2006	aaaa aaaa	PPU read/write address (two writes: MSB, LSB)
;----------￾-------￾----------￾---------------------------------------------'
;| $2006   |  W2   | aaaaaaaa | PPU Memory Address                [PPUADDR] |
;|         |       |          |                                             |
;|         |       |          |  Specifies the address in VRAM in which     |
;|         |       |          |  data should be read from or written to.    |
;|         |       |          |  This is a double-write register. The high- |
;|         |       |          |  byte of the 16-bit address is written      |
;|         |       |          |  first, then the low-byte.                  |
;----------￾-------￾----------￾---------------------------------------------'

PPU_ADDR = $2006 ; THIS IS THE ADDRESS OF THE PPU MEMORY

; PPUDATA	$2007	dddd dddd	PPU data read/write
;----------￾-------￾----------￾---------------------------------------------'
;| $2007   | RW    | dddddddd | PPU I/O Register                    [PPUIO] |
;|         |       |          |                                             |
;|         |       |          |  Used to read/write to the address spec-    |
;|         |       |          |  ified via $2006 in VRAM.                   |
;----------￾-------￾----------￾---------------------------------------------'
PPU_DATA = $2007 

; OAMADDR	$2003	aaaa aaaa	OAM read/write address
; SPRITE MEMORY ADDRESS
;----------￾-------￾----------￾---------------------------------------------'
;| $2003   |  W    | aaaaaaaa | Sprite Memory Address             [SPRADDR] |
;|         |       |          |                                             |
;|         |       |          |  Specifies the address in Sprite RAM to     |
;|         |       |          |  access via $2004 (see Section #9).         |
;----------￾-------￾----------￾---------------------------------------------'
OAM_ADDR = $2003

; OAMDATA	$2004	dddd dddd	OAM data read/write
;----------￾-------￾----------￾---------------------------------------------'
;| $2004   |  W    | dddddddd | Sprite I/O Register                 [SPRIO] |
;|         |       |          |                                             |
;|         |       |          |  Used to read/write to the address spec-    |
;|         |       |          |  ified via $2003 in Sprite RAM.             |
;----------￾-------￾----------￾---------------------------------------------'
OAM_DATA = $2004

    ;======================================================================================
    ; PPU CTRL FLAGS
    ; VPHB SINN
    ; 7654 3210
    ; |||| ||||
    ; |||| |||+----\
    ; |||| |||      |---> Nametable Select  (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
    ; |||| ||+-----/
    ; |||| |+----> VRAM address increment per CPU read/write of PPUDATA (0: 1 across; 1: 32 down)
    ; |||| +-----> Sprite Tile Address Select (0: $0000; 1: $1000)
    ; ||||                              
    ; |||+-------> Background Tile Address Select (0: $0000; 1: $1000)
    ; ||+--------> Sprite Hight (0: 8x8; 1: 8x16)
    ; |+---------> PPU Master / Slave (not sure if this is used)
    ; +----------> NMI enable (0: off; 1: on)
    ;======================================================================================

.define PPU_CTRL_NMI_ENABLE     #%10000000
.define PPU_CTRL_MASTER_SLAVE   #%01000000
.define PPU_CTRL_16_PX_HEIGHT   #%00100000
.define PPU_CTRL_BACKGROUND     #%00010000
.define PPU_CTRL_SPRITE         #%00001000
.define PPU_CTRL_INCREMENT_MODE #%00000100
.define PPU_CTRL_DEFAULT        #%10011100

.define PPU_CTRL $2000
;===========================================================================
; PPU MASK MODES
; 7  bit  0
; ---- ----
; BGRs bMmG
; |||| ||||
; |||| |||+- Greyscale (0: normal color, 1: produce a greyscale display)
; |||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
; |||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
; |||| +---- 1: Show background
; ||||
; |||+------ 1: Show sprites
; ||+------- Emphasize red*
; |+-------- Emphasize green*
; +--------- Emphasize blue*
;===========================================================================
PPU_MASK_EMPH_BLUE = %10000000
PPU_MASK_EMPH_GREEN = %01000000
PPU_MASK_EMPH_RED = %00100000
PPU_MASK_SHOW_SPRITES = %00010000
PPU_MASK_SHOW_BACKGROUND = %00001000
PPU_MASK_SHOW_SPRITES_L8 = %00000100
PPU_MASK_SHOW_BACKGROUND_L8 = %00000010
PPU_MASK_GRAYSCALE = %00000001

PPU_MASK	= $2001

; VSO- ----	vblank (V), sprite 0 hit (S), sprite overflow (O), read resets write pair for $2005/2006
;----------￾-------￾----------￾---------------------------------------------'
;| $2002   | R     | vhs00000 | PPU Status Register               [PPUSTAT] |
;|         |       |          |                                             |
;|         |       |          |  v = VBlank Occurance Flag                  |
;|         |       |          |         0 = No VBlank                       |
;|         |       |          |         1 = VBlank                          |
;|         |       |          |  h = Hit Occurance Flag                     |
;|         |       |          |         0 = No hit                          |
;|         |       |          |         1 = Refresh has hit Sprite #0       |
;|         |       |          |  s = Sprite Count Max                       |
;|         |       |          |         0 = Less than 8 sprites on the      |
;|         |       |          |             current scanline                |
;|         |       |          |         1 = More than 8 sprites on the      |
;|         |       |          |             current scanline                |
;|         |       |          |                                             |
;|         |       |          | NOTE: Reading this register resets Bit 7,   |
;|         |       |          |       also also resets the Background       |
;|         |       |          |       Scroll Register bits as well.         |
;|         |       |          | NOTE: Bit 6 is reset to 0 at the beginning  |
;|         |       |          |       of the next refresh.                  |
;|         |       |          | NOTE: Bit 6 is not set until the first      |
;|         |       |          |       actual pixel (i.e. non-transparent)   |
;|         |       |          |       is drawn. Therefore, if you have a    |
;|         |       |          |       sprite (8x8) which has it's first 4   |
;|         |       |          |       pixels as transparent, and it's 5th   |
;|         |       |          |       as a non-transparent value, Bit 6     |
;|         |       |          |       will be set after the 5th pixel is    |
;|         |       |          |       found & drawn.                        |
;|         |       |          | NOTE: If Bit 5 is set, the PPU will NOT let |
;|         |       |          |       you write to VRAM.                    |
;----------￾-------￾----------￾---------------------------------------------'
PPU_STATUS = $2002

; xxxx xxxx	fine scroll position (two writes: X, Y)
;----------￾-------￾----------￾---------------------------------------------'
;| $2005   |  W2   | dddddddd | Background Scroll Register        [BGSCROL] |
;|         |       |          |                                             |
;|         |       |          |  Used to scroll the screen vertically and   |
;|         |       |          |  horizontally. This is a double-write       |
;|         |       |          |  register.                                  |
;|         |       |          |                                             |
;|         |       |          |  BYTE 1: Horizontal Scroll                  |
;|         |       |          |  BYTE 2: Vertical Scroll                    |
;|         |       |          |                                             |
;|         |       |          |  The scrolled data will span across multip- |
;|         |       |          |  le Name Tables. The layout is as follows:  |
;|         |       |          |                                             |
;|         |       |          |      --------------------------¨            |
;|         |       |          |      | #2 ($2800) | #3 ($2C00) |            |
;|         |       |          |      A------------￾------------'            |
;|         |       |          |      | #0 ($2000) | #1 ($2400) |            |
;|         |       |          |      A-------------------------U            |
;|         |       |          |                                             |
;|         |       |          | NOTE: If the Vertical Scroll value is >239, |
;|         |       |          |       it will be ignored. Some emulators    |
;|         |       |          |       write 0 to the Vertical Scroll if     |
;|         |       |          |       the value is >239.                    |
;|         |       |          | NOTE: Remember, there is only enough VRAM   |
;|         |       |          |       for two (2) Name Tables.              |
;|         |       |          | NOTE: After a VBL occurs, the next write    |
;|         |       |          |       will control the Horizontal Scroll.   |
;----------￾-------￾----------￾---------------------------------------------'

PPU_SCROLL = $2005

OAM_DMA = $4014	; aaaa aaaa	OAM DMA high address

.segment "CODE"
.proc load_attribute 
    lda PPU_STATUS        ; read PPU status to reset the high/low latch
    lda #$23    ; 27 ; 2B ; 2F
    sta PPU_ADDR          ; write the high byte of $23C0 address

    lda #$C0
    sta PPU_ADDR          ; write the low byte of $23C0 address

    ldx #$00              ; start out at 0
    LoadAttributeLoop:
        lda #%00000000 ; attribute, x      ; load data from address (attribute + the value in x)
        sta PPU_DATA          ; write to PPU
        inx                   ; X = X + 1
        cpx #$40              ; Compare X to hex $08, decimal 8 - copying 8 bytes
    bne LoadAttributeLoop  ; Branch to LoadAttributeLoop if compare was Not Equal to zero


    lda PPU_STATUS        ; read PPU status to reset the high/low latch
    lda #$2B    ; 27 ; 2B ; 2F
    sta PPU_ADDR          ; write the high byte of $23C0 address

    lda #$C0
    sta PPU_ADDR          ; write the low byte of $23C0 address

    ldx #$00              ; start out at 0
    LoadAttributeLoop_2:
        lda #%00000000 ; attribute, x      ; load data from address (attribute + the value in x)
        sta PPU_DATA          ; write to PPU

        inx                   ; X = X + 1
        cpx #$40              ; Compare X to hex $08, decimal 8 - copying 8 bytes
    bne LoadAttributeLoop_2  ; Branch to LoadAttributeLoop if compare was Not Equal to zero

    rts
.endproc

.proc load_palettes

    lda PPU_STATUS             ; read PPU status to reset the high/low latch

    ; PPUADDR	$2006	aaaa aaaa	PPU read/write address (two writes: MSB, LSB)
    ;----------￾-------￾----------￾---------------------------------------------'
    ;| $2006   |  W2   | aaaaaaaa | PPU Memory Address                [PPUADDR] |
    ;|         |       |          |                                             |
    ;|         |       |          |  Specifies the address in VRAM in which     |
    ;|         |       |          |  data should be read from or written to.    |
    ;|         |       |          |  This is a double-write register. The high- |
    ;|         |       |          |  byte of the 16-bit address is written      |
    ;|         |       |          |  first, then the low-byte.                  |
    ;----------￾-------￾----------￾---------------------------------------------'
    lda #$3F
    sta PPU_ADDR             ; write the high byte of $3F00 address

    lda #$00
    sta PPU_ADDR             ; write the low byte of $3F00 address

    ldx #$00              ; start out at 0
    LoadPalettesLoop:
    lda palette_background, x        ; load data from address (palette + the value in x)
                            ; 1st time through loop it will load palette+0
                            ; 2nd time through loop it will load palette+1
                            ; 3rd time through loop it will load palette+2
                            ; etc

    ; PPUDATA	$2007	dddd dddd	PPU data read/write
    ;----------￾-------￾----------￾---------------------------------------------'
    ;| $2007   | RW    | dddddddd | PPU I/O Register                    [PPUIO] |
    ;|         |       |          |                                             |
    ;|         |       |          |  Used to read/write to the address spec-    |
    ;|         |       |          |  ified via $2006 in VRAM.                   |
    ;----------￾-------￾----------￾---------------------------------------------'
    sta PPU_DATA             ; write to PPU
    ;    WRITE_PPU_DATA

    inx                   ; X = X + 1
    cpx #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
    bne LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
    rts
.endproc

.proc oam_dma
    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
;=============================================
; PPU_MASK_EMPH_BLUE          = %10000000
; PPU_MASK_EMPH_GREEN         = %01000000
; PPU_MASK_EMPH_RED           = %00100000
; PPU_MASK_SHOW_SPRITES       = %00010000
; PPU_MASK_SHOW_BACKGROUND    = %00001000
; PPU_MASK_SHOW_SPRITES_L8    = %00000100
; PPU_MASK_SHOW_BACKGROUND_L8 = %00000010
; PPU_MASK_GRAYSCALE          = %00000001
;=============================================

    lda #(PPU_MASK_SHOW_SPRITES|PPU_MASK_SHOW_BACKGROUND|PPU_MASK_SHOW_SPRITES_L8|PPU_MASK_SHOW_BACKGROUND_L8) ; PPU_MASK_SHOW_SPRITES
    sta PPU_MASK
    set OAM_ADDR, #0
    set OAM_DMA, #$02

    rts
.endproc

; this moves all the sprites in oam memory offscreen by setting y to 255
.proc clear_sprites
	lda #255
	ldx #0
	clear_sprites_loop:
		sta oam, X
		inx
		inx
		inx
		inx
        bne clear_sprites_loop
    rts
.endproc

; clear the entire background on a vblank
.proc clear_background_all
		jsr wait_for_vblank

        ldy #$20
		outer_background_clear_loop:
	        lda PPU_STATUS        ; PPU_STATUS = $2002
			sty PPU_ADDR

			lda #0
			tax
			sta PPU_ADDR
			inner_background_clear_loop:
	            sta PPU_DATA
				inx
				bne inner_background_clear_loop
			iny
			cpy #$24
		bne outer_background_clear_loop

        ldy #$28
		outer_background_clear_loop2:
	        lda PPU_STATUS        ; PPU_STATUS = $2002
			sty PPU_ADDR

			lda #0
			tax
			sta PPU_ADDR
			inner_background_clear_loop2:
	            sta PPU_DATA
				inx
				bne inner_background_clear_loop2
			iny
			cpy #$2C
		bne outer_background_clear_loop2

	rts
.endproc


.segment "OAM"
oam: .res 256        ; sprite OAM data to be uploaded by DMA

