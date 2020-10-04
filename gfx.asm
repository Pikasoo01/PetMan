;*******************************************
	
DrawScreen:	
	lda #0
	sta dpy
	sec
	sbc ppx
	sta scr_x

    lda #2
    sta tst_src+1
	lda dpx
    asl
    asl
	sta tst_src
	bcc +
	inc tst_src+1
+	
    lda dpx
    sec
    sbc #2
    sta colx
	
tst_loopx:	
	lda #0
	sta scr_y
	sta dpy
tst_loopy:
	lda $FFFF
tst_src = *-2
    pha
    and #$F
	sta block_id
	jsr DrawSquare
	inc dpy
    lda dpy
	cmp #7 
    beq tst_jmp2
    pla
    lsr
    lsr
    lsr
    lsr
    sta block_id
	jsr DrawSquare
	inc tst_src
	inc dpy
	
	jmp tst_loopy
tst_jmp2:
    pla
	inc tst_src
	bne +
	inc tst_src+1
+
    jsr draw_player_monster
    inc colx
	clc
	lda scr_x
	adc #3
	sta scr_x
	cmp #40
	bmi tst_loopx
	
    jsr draw_player_monster
    inc colx
    jsr draw_player_monster

	rts


draw_player_monster:
    lda scr_x
    sta dpm_scrx

    lda playerPosX
    cmp colx
    bne +
    jsr DrawPlayer
+   
    lda #0
    sta monst
-
    ldx monst
    lda monsters_px,x
    cmp colx
    bne +
    ;draw monster
    lda monsters_px,X
	sta monster_px
	lda monsters_px2,X
	sta monster_px2
	lda monsters_py,X
	sta monster_py
	lda monsters_py2,X
	sta monster_py2
	lda monsters_type,X
	sta monster_type
    jsr DrawMonster
+
    inc monst
    lda monst
    cmp #16
    bne -

    lda #0
dpm_scrx = *-1
    sta scr_x
    rts


	
;*******************************************
	
DrawSquare:
    lda #>block_data
    sta ds_src+1
	lda block_id
	asl
	asl
	asl
	clc
	adc block_id
	sta ds_src	;point to sprite data
    bcc +
    inc ds_src+1
+
	lda scr_y
	asl
	tax
	lda screenOffset,x
	sta ds_dst
	lda screenOffset+1,x
	sta ds_dst+1
	
	ldy scr_x
	ldx #0
-
	lda scr_y
	cmp #21
	bcs +
	cpy #40
	bcs +
	lda block_data,x
ds_src = *-2		;used as param
	sta $FFFF,y
ds_dst = *-2
+
	iny
	inx
	cpx #3
	beq ds_addptr
	cpx #6
	beq ds_addptr
	cpx #9
	bne -
	inc scr_y
ds_quit:
	rts

ds_addptr:
	inc scr_y
	lda scr_y
	asl
	tay
	lda screenOffset,y
	sta ds_dst
	lda screenOffset+1,y
	sta ds_dst+1
		
	ldy scr_x
	jmp -
	


;*******************************************
DrawPlayer:
	;y pos
	lda playerPosY2
	lsr
	lsr
	lsr
	clc
	adc playerPosY
	clc
	adc playerPosY
	clc
	adc playerPosY
	sta scr_y
	
	;x pos
	lda playerPosX
	sec
	sbc dpx
	sta scr_x
	clc
	asl
	adc scr_x
	sta scr_x
	lda playerPosX2
	lsr
	lsr
	lsr
	sec
	sbc ppx
	clc
	adc scr_x
	sta scr_x
	ldx #spritebase
	lda runForce
	beq +
	lda fps
	lsr
	and #1
	clc
	adc #sprite_walk
	tax
	lda runForce
	bpl +
	inx
	inx
+
	lda jmpCnt
	beq +
	lda #sprite_jmp
	clc
	adc playerDir
	tax
+
	stx block_id
	jsr DrawSquare
	rts

;*******************************************
DrawMonster:
	;y pos
	lda monster_py2
	lsr
	lsr
	lsr
	clc
	adc monster_py
	clc
	adc monster_py
	clc
	adc monster_py
	sta scr_y
	
	;x pos
	lda monster_px
	sec
	sbc dpx
	sta scr_x
	clc
	asl
	adc scr_x
	sta scr_x
	lda monster_px2
	lsr
	lsr
	lsr
	sec
	sbc ppx
	clc
	adc scr_x
	sta scr_x

	lda fps
	lsr
	and #1
	clc
	adc #monsterBase
	adc monster_type
	adc monster_type
	tax
	
	stx block_id
	jsr DrawSquare
	rts


;**********************************************************
;
; clear the whole screen
;
ClearScreen:
    ldy #0
    lda #$20
-   sta ScreenBase,y
    sta ScreenBase+256,y
    sta ScreenBase+512,y
    sta ScreenBase+768,y
    iny
    bne -
    rts

;********************************************************
;   A = value
;   vector1 = position to write
IntToStr:
    ldy #0
    ldx #$30
    ;is it over 10
-   cmp #10
    bcc +
    sec
    sbc #10
    inx
    jmp -
+   cpx #$30
    beq +
    pha
    txa
    sta (vector1),y
    pla
    iny
+   clc
    adc #$30
    sta (vector1),y
    rts


;********************************************************
DisplayStage:
    ldy #0
-   lda ds_txt1,y
    sta ScreenBase+415,y
    iny
    cpy #5
    bne -
    ldy #0
-   lda ds_txt2,y
    sta ScreenBase+496,y
    iny
    cpy #4
    bne -
        ;write the value
    lda #<(ScreenBase+421)
    sta vector1
    lda #>(ScreenBase+421)
    sta vector1+1
    lda currentStage
    jsr IntToStr

    lda #<(ScreenBase+501)
    sta vector1
    lda #>(ScreenBase+501)
    sta vector1+1
    lda playerLives
    jsr IntToStr
    rts

ds_txt1: !scr "stage"
ds_txt2: !scr "life"
ds_txt3: !scr "gems"



;************************************************************
DisplayCoins:
    lda #<(ScreenBase+77)
    sta vector1
    lda #>(ScreenBase+77)
    sta vector1+1
    lda #$20
    sta ScreenBase+78   ;clear second char
    lda coinCnt
    jsr IntToStr
    rts


;*************************************************************
DisplayHeader:
    jsr DisplayCoins

    ldy #0
-   lda ds_txt1,y
    sta ScreenBase+41,y
    iny
    cpy #5
    bne -

    ldy #0
-   lda ds_txt3,y
    sta ScreenBase+72,y
    iny
    cpy #4
    bne -

    lda #<(ScreenBase+47)
    sta vector1
    lda #>(ScreenBase+47)
    sta vector1+1
    lda currentStage
    jsr IntToStr
    rts


;*************************************************************
DisplayWelcomScr:
    jsr ClearScreen

    ldy #0
-   lda dws_txt1,y
    sta ScreenBase+217,y
    iny
    cpy #6
    bne -

    ldy #0
-   lda dws_txt2,y
    sta ScreenBase+299,y
    iny
    cpy #2
    bne -

    ldy #0
-   lda dws_txt3,y
    sta ScreenBase+369,y
    iny
    cpy #21
    bne -

    ldy #0
-   lda dws_txt4,y
    sta ScreenBase+730,y
    iny
    cpy #20
    bne -

    jsr WhaitForSpace
    rts


dws_txt1: !scr "petman"
dws_txt2: !scr "by"
dws_txt3: !scr "christian aka pikasoo"
dws_txt4: !scr "press space to start"

;*************************************************************
DisplayGameOver:
    jsr ClearScreen

    ldy #0
-   lda dgo_txt1,y
    sta ScreenBase+495,y
    iny
    cpy #9
    bne -

    rts

dgo_txt1: !scr "game over"


;*************************************************************
DisplayEndGame:
    jsr ClearScreen

    ldy #0
-   lda deg_txt0,y
    sta ScreenBase+412,y
    iny
    cpy #15 
    bne -

    lda #15
    jsr Delay

    ldy #0
-   lda deg_txt1,y
    sta ScreenBase+488,y
    iny
    cpy #24 
    bne -

    lda #15
    jsr Delay

    ldy #0
-   lda deg_txt2,y
    sta ScreenBase+569,y
    iny
    cpy #21 
    bne -

    rts

deg_txt0: !scr "congratulations"
deg_txt1: !scr "you made it to the end!!"
deg_txt2: !scr "thank you for playing"


;**************************************************************
displayMapCompleted:
    ;find the plate start
    ldx playerPosX
    dex
    ldy playerPosY
    iny
    jsr GetMapBlock
    cmp #12
    beq +
    inx
+
    ;calc start x on screen
    txa
	sec
	sbc dpx
	sta scr_x
	clc
	asl
	adc scr_x
	sta scr_x
	lda #0
	sec
	sbc ppx
	clc
	adc scr_x
	sta scr_x

    ;loop lowering all
    lda #0
    sta scr_y
    lda #123
    sta temp16
dmc_loop1:
    ldy #38
dmc_loopy:
    lda screenOffset,y
    sta dmc_v1
    lda screenOffset+1,y
    sta dmc_v1+1
    lda screenOffset+2,y
    sta dmc_v2
    lda screenOffset+3,y
    sta dmc_v2+1
    lda #9
    sta temp8
    ldx scr_x
dmc_loopx:
    lda $ffff,X
dmc_v1 = *-2
    sta $ffff,X
dmc_v2 = *-2
    inx
    dec temp8
    lda temp8
    bne dmc_loopx

    dey
    dey
    cpy #$FE
    bne dmc_loopy

    ;draw top
    lda screenOffset
    sta dmc_v3
    lda screenOffset+1
    sta dmc_v3+1

    lda scr_x
    clc
    adc #8
    tax

    lda temp16
    sta dmc_bd
    ldy #2
-
    lda block_data,y
dmc_bd = *-2
    sta $ffff,X
dmc_v3 = *-2
    dex
    dey
    cpy #$ff
    bne -

    dec temp16
    dec temp16
    dec temp16
    lda temp16
    cmp #114
    bne +
    lda #123
    sta temp16
+


    lda #2
    jsr Delay

    inc scr_y
    lda scr_y
    cmp #21
    bne dmc_loop1
    rts



