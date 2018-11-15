.segment "CODE"

; this is like a x = y call where x is set to the value of y
.macro set set_var, from
    lda from
    sta set_var
.endmacro

; this procedure will loop until the next vblank
.proc wait_for_vblank
	bit PPU_STATUS      ; $2002
    vblank_wait:
		bit PPU_STATUS  ; $2002
		bpl vblank_wait

    rts
.endproc

; clear out all the ram on the reset press
.macro clear_ram
	lda #0
	ldx #0
	clear_ram_loop:
		sta $0000, X
		sta $0100, X 
		sta $0200, X
		sta $0300, X
		sta $0400, X
		sta $0500, X
		sta $0600, X
		sta $0700, X
		inx
		bne clear_ram_loop
.endmacro

; this code will be called from the nmi
.macro printf_nmi STRING, XPOS, YPOS ; 32, 128
    .local ROW
    .local COL
    .local BYTE_OFFSET_HI
    .local BYTE_OFFSET_LO
    
    ROW = YPOS / 8 ; 128 / 8 = 16
    COL = XPOS / 8 ; 32 /  8  = 4
    BYTE_OFFSET_HI = (ROW * 32 + COL) / 256 + 32 ; (16 * 32 + 4) / 256 + 20
    BYTE_OFFSET_LO = (ROW * 32 + COL) .mod 256

    lda PPU_STATUS        ; PPU_STATUS = $2002

    lda #BYTE_OFFSET_HI
    sta PPU_ADDR          ; PPU_ADDR = $2006
    lda #BYTE_OFFSET_LO
    sta PPU_ADDR          ; PPU_ADDR = $2006

    .repeat .strlen(STRING), I
        lda #.strat(STRING, I)
        sta PPU_DATA      
    .endrep
.endmacro