;****************************************************
LoadMap:
    lda #0
    sta map_completed
    jsr ClearScreen
    jsr DisplayStage

    lda #45
    jsr Delay


    ;unpack current map
    lda currentStage
    asl
    tax
    lda Map_Data_Ptr-2,x
    sta vector1
    lda Map_Data_Ptr-1,x
    sta vector1+1

    lda #2
    sta lm_ptr1+1

    lda #0
    sta lm_ptr1
    sta dpx
    sta dpy
lm_loop_x:
    ldy #0
    lda (vector1),y     ;map used block
    sta temp8
    iny
        ;process all 8 block
    ldx #0
    stx scr_y
lm_loop_y:
    lda #0
    sta block_id
    lsr temp8
    bcc +
    jsr load_block_data
    sta block_id
+   
    lsr temp8
    bcc +
    jsr load_block_data
    asl
    asl
    asl
    asl
    ora block_id
    sta block_id
+   
    lda block_id
    sta $0200
lm_ptr1 = *-2
    inc lm_ptr1
    lda lm_ptr1
    bne +
    inc lm_ptr1+1
+   inc scr_y
    lda scr_y
    cmp #4
    bne lm_loop_y

    cpx #1
    bne +
    iny
+
    tya
    clc
    adc vector1
    sta vector1
    lda #0
    adc vector1+1
    sta vector1+1

    inc dpx
    lda dpx
    cmp #128
    bne lm_loop_x    


    ;clean monster
    ldx #0
    lda #0
-   sta monsters_px,X
    inx
    cpx #128
    bne -

    ;load monster

    ldx #0
    ldy #0
-   lda (vector1),y
    sta monsters_px,x
    iny
    lda (vector1),y
    sta monsters_py,x
    iny
    lda (vector1),y
    sta monsters_type,x
    iny
        ;preset some of the param
    cmp #0
    bne +
    pha
    lda #1
    sta monsters_dir,x
    pla
+
    cmp #3
    bne +
    pha
    lda #8
    sta monsters_py,x
    pla
+
    cmp #1
    bne +
    lda #12
    sta monsters_spd,x
+
    inx
    cpy #48
    bne -

    jsr DisplayHeader

    lda #0
	sta dpy
	sta dpx		;position in map
	sta ppx
	sta jmpPhase
	sta jmpForce
	sta playerPosY
	sta playerPosY2
	sta playerPosX2
	sta runForce
	sta playerDir
    sta playerDie

	lda #2
	sta playerPosX
	

    rts


load_block_data:
    lda (vector1),y

    cpx #1
    beq +
    and #$f
    inx
    rts
+  
    lsr
    lsr
    lsr
    lsr
    ldx #0
    iny
    rts




;*********************************************
; X,Y = the map block
GetMapBlock:
    lda #2
    sta gmb_off+1
    txa
    asl
    asl
    sta gmb_off
    bcc +
    inc gmb_off+1
+
    sty gmb_y   ;save y beafor scrapping it
    tya
    lsr
    tay
    lda $ffff,Y
gmb_off = *-2
    ldy #$ff
gmb_y = *-1

    bcc +
    lsr
    lsr
    lsr
    lsr
    rts
+
    and #$f
    rts


;*********************************************
; X,Y = the map block A = value
PutMapBlock:
    sta temp8
    lda #2
    sta vector1+1
    txa
    asl
    asl
    sta vector1
    bcc +
    inc vector1+1
+
    sty pmb_y
    tya
    lsr
    tay
    lda (vector1),Y
    
    bcc +
    asl temp8
    asl temp8
    asl temp8
    asl temp8
    and #$f
    ora temp8
    sta (vector1),Y
-
    ldy #$ff
pmb_y = *-1
    rts
+
    and #$f0
    ora temp8
    sta (vector1),Y
    jmp -