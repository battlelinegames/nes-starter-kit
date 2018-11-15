.segment "CODE"
reset:
	sei                 ; mask interrupts

	lda #0              ; clear the A register
	sta PPU_CTRL        ; $2000 ; disable NMI
	sta PPU_MASK        ; $2001 ; disable rendering
    sta PPU_SCROLL
    sta PPU_SCROLL

	cld                 ; disable decimal mode
	ldx #$FF
	txs                 ; initialize stack

    ; execute this code during first vblank after reset
    jsr wait_for_vblank                             ; utils.asm

    ; clear out all the ram by setting everything to 0
    clear_ram                                       ; utils.asm

    ; move all the sprites in oam memory offscreen by setting y to #$ff
    jsr clear_sprites                               ; utils.asm

    ; wait for next vblank
    jsr wait_for_vblank                             ; utils.asm

    jsr clear_background_all

    ;======================================================================================
    ; PPU CTRL FLAGS
    ; VPHB SINN
    ; 7654 3210
    ; |||| ||||
    ; |||| |||+----\
    ; |||| |||      |---> Nametable Select  (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
    ; |||| ||+-----/
    ; |||| |+----> Increment Mode (0: increment by 1, across; 1: increment by 32, down)
    ; |||| +-----> Sprite Tile Address Select (0: $0000; 1: $1000)
    ; ||||                              
    ; |||+-------> Background Tile Address Select (0: $0000; 1: $1000)
    ; ||+--------> Sprite Hight (0: 8x8; 1: 8x16)
    ; |+---------> PPU Master / Slave (not sure if this is used)
    ; +----------> NMI enable (0: off; 1: on)
    ;======================================================================================

    ; set the ppu control register to enable nmi and sprite tile rendering
/*
    set palette_init, #0
    lda palette_init
;    cmp #2
    bne palette_loaded ; bcs palette_loaded
        jsr load_palettes
        inc palette_init
    palette_loaded:
    */
    jsr load_palettes

    jsr load_attribute

;    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE

    lda PPU_STATUS ; $2002
    set PPU_SCROLL, #0
    sta PPU_SCROLL
    set PPU_CTRL, PPU_CTRL_DEFAULT 

    set nmi_ready, #1

    jmp game_loop   ; start the wait loop


