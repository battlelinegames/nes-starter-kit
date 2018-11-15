;======================================================================================
; GAMEPAD DATA FLAGS
; 76543210
; ||||||||
; |||||||+--> A Button
; ||||||+---> B Button
; |||||+----> SELECT Button
; ||||+-----> START Button
; |||+------> UP Direction
; ||+-------> DOWN Direction
; |+--------> LEFT Direction
; +---------> RIGHT Direction
;======================================================================================

; These are the bit flags the are used by the vars
.define PRESS_A        #%00000001
.define PRESS_B        #%00000010
.define PRESS_SELECT   #%00000100
.define PRESS_START    #%00001000
.define PRESS_UP       #%00010000
.define PRESS_DOWN     #%00100000
.define PRESS_LEFT     #%01000000
.define PRESS_RIGHT    #%10000000

.segment "ZEROPAGE"
    gamepad_press: .res 1
    gamepad_last_press: .res 1
    gamepad_new_press: .res 1
    gamepad_release: .res 1

.segment "CODE"

GAMEPAD_REGISTER = $4016

; initialize the gamepad.  this is called from the set_gamepad
.proc gamepad_init
    set gamepad_last_press, gamepad_press       ; save gamepad_press to gamepad_last_press

    ; Setup the gamepad register so we can start pulling gamepad data
    set  GAMEPAD_REGISTER, #1
    set  GAMEPAD_REGISTER, #0

    ; the prior set call set the A register to #0, so no need to load it again
    sta gamepad_press ; clear out our gamepad press byte

    rts 
.endproc

; use this macro to figure out if a specific button was pressed
.macro button_press_check button
    .local @not_pressed
    lda GAMEPAD_REGISTER
    and #%00000001
    beq @not_pressed    ; beq key not pressed
        lda button
        ora gamepad_press
        sta gamepad_press
    @not_pressed:   ; key not pressed
.endmacro

; initialize and set the gamepad values
.proc set_gamepad

    jsr gamepad_init ; prepare the gamepad register to pull data serially

    gamepad_a:
        lda GAMEPAD_REGISTER
        and #%00000001
        sta gamepad_press

    gamepad_b:
        button_press_check PRESS_B

    gamepad_select:
        button_press_check PRESS_SELECT

    gamepad_start:
        button_press_check PRESS_START

    gamepad_up:
        button_press_check PRESS_UP

    gamepad_down:
        button_press_check PRESS_DOWN

    gamepad_left:
        button_press_check PRESS_LEFT

    gamepad_right:
        button_press_check PRESS_RIGHT
    
    ; to find out if this is a newly pressed button, load the last buttons pressed, and 
    ; flipp all the bits with an eor #$ff.  Then you can AND the results with current
    ; gamepad pressed.  This will give you what wasn't pressed previously, but what is
    ; pressed now.  Then store that value in the gamepad_new_press
    lda gamepad_last_press 
    eor #$ff
    and gamepad_press

    sta gamepad_new_press ; all these buttons are new presses and not existing presses

    ; in order to find what buttons were just released, we load and flip the buttons that
    ; are currently pressed  and and it with what was pressed the last time.
    ; that will give us a button that is not pressed now, but was pressed previously
    lda gamepad_press       ; reload original gamepad_press flags
    eor #$ff                ; flip the bits so we have 1 everywhere a button is released

    ; anding with last press shows buttons that were pressed previously and not pressed now
    and gamepad_last_press  

    ; then store the results in gamepad_release
    sta gamepad_release  ; a 1 flag in a button position means a button was just released
    rts
.endproc