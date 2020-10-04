;**********************************************************************
; game logic
;

ApplyPlayerLogic:
	;if do jump we have to set the flags
	lda doJump
	beq apl_test2
	lda jmpCnt
	cmp #5
	beq apl_test2	;no more jump power allowed
	inc jmpCnt
	lda jmpForce
	clc
	adc #35
	sta jmpForce
	lda #1
	sta jmpPhase
	jmp +
apl_test2:
	lda jmpCnt
	beq +
	lda #5
	sta jmpCnt
+

	lda jmpCnt
	beq +
	lda fps
	and #3
	cmp #0
	beq apl_test4
+
	lda doRight
	beq +
	;accelerate
	lda #0
	sta playerDir
	lda runForce
	cmp #8
	bpl +
	inc runForce
+
	lda doLeft
	beq +
	;accelerate
	lda #1
	sta playerDir
	lda runForce
	cmp #$F9
	bmi +
	dec runForce
+

	lda doRight
	clc
	adc doLeft
	cmp #0
	bne apl_test4
	lda jmpCnt
	bne apl_test4
	;test if must slow down
	lda runForce
	cmp #$ff
	bne +
	lda #0
+
	lsr
	cmp #8
	bcc +
	ora #$80
+
	sta runForce
apl_test4:



	;apply vertical motion
	lda jmpPhase
	beq apl_vm2

	lda jmpForce
	lsr
	lsr
	cmp #32
	bcc +
	lda #32	;max
+	sta temp8
	sec
	lda jmpForce
	sbc temp8
	sta jmpForce
	lsr temp8
	sec
	lda playerPosY2
	sbc temp8
	sta playerPosY2
	bcs +
		;changed cell
		clc
		adc #24
		sta playerPosY2
		dec playerPosY
		;can we be there?

		ldy playerPosY
		jsr TestSolidBlock
		bcc +			
		;nop, cant be there, bounce down
		lda #2
		sta playerPosY2
		lda #0
		sta jmpPhase
		inc playerPosY

		;if the block = 2 then we pop a coin
		ldy playerPosY
		dey
		ldx #0
		lda playerPosX2
		cmp #16
		bcc first_block
		inx
		tya 
		clc
		adc #8
		tay
first_block:
		lda last_block,x
		cmp #2
		bne +
        ldx playerPosX
		lda #3
		jsr PutMapBlock
		dey
		lda #4
		jsr PutMapBlock

+	
	lda jmpForce
	cmp #16
	bcs +
	lda #0			;done jumping
	sta jmpPhase
+
	jmp apl_hm
apl_vm2:
	;here we try to do gravity control

	;test cell under, is it wall?
	ldy playerPosY
	iny
	jsr TestSolidBlock
	bcs apl_ground
+	;so we fall
	lda #5
	sta jmpCnt ;cant jump
	lda jmpForce
	bne +
	lda #128	;min to start falling
+
	lsr
	lsr
	cmp #32
	bcc +
	lda #32		;max speed
+
	sta temp8
	lda jmpForce
	clc
	adc temp8
	sta jmpForce
	lsr temp8
	lda playerPosY2
	clc
	adc temp8
	sta playerPosY2
	cmp #24
	bcc apl_hm
		;we go down a cell
	sbc #24
	sta playerPosY2
	inc playerPosY
	ldy playerPosY 
    lda playerPosY2
    iny
	jsr TestSolidBlock
	bcc apl_hm

apl_ground:
	lda #0
	sta jmpForce
	sta jmpCnt
	lda #0
	sta playerPosY2
    ;is it a crumble
    lda fps
    and #1
    beq apl_hm  ;crumble only half speed
    lda last_block
    cmp #12
    bne +
    sta map_completed
    rts
+
    cmp #7
    bcc +
    cmp #11
    bcs +
    jmp apl_crumb1
+   lda last_block2
    cmp #7
    bcc apl_hm
    cmp #11
    bcs apl_hm
    ldx playerPosX
    inx
    jmp +
apl_crumb1:
    ldx playerPosX
+   ldy playerPosY
    iny
    clc
    adc #1
    cmp #11
    bne +
    lda #0
+   jsr PutMapBlock

apl_hm:
	lda runForce
	beq apl_done
	clc
	adc playerPosX2
	sta playerPosX2
	cmp #24
	bcc +
	bmi apl_testleft
	inc playerPosX
	sec
	sbc #24
	sta playerPosX2
+	lda runForce
	bmi apl_done
	ldx playerPosX
	inx
	jsr TestSolidBlockV
	bcc apl_done
	lda #0
	sta runForce
	sta playerPosX2
	jmp apl_done
apl_testleft
	dec playerPosX
	clc
	adc #24
	sta playerPosX2
	ldx playerPosX
	jsr TestSolidBlockV
	bcc apl_done
	lda #0
	sta runForce
	sta playerPosX2
	inc playerPosX

apl_done:
	;move screen if needed
	lda runForce
	bmi apl_scroll_left
	beq apl_scroll
		;scroll right if needed
-
	jsr GetPlayerScrPos
	cmp #18
	bmi apl_leave ;in the proper zone
	sec
	sbc #18
	cmp #2
	bmi +
	lda #2		;max speed
+	clc
	adc ppx
	cmp #3
	bmi +
	inc dpx
	sec
	sbc #3
+
	sta ppx
	lda dpx
	cmp #114
	bmi +
	lda #114	;max scroll
	sta dpx
	lda #0
	sta ppx
+	
	jmp apl_leave

apl_scroll_left:
	jsr GetPlayerScrPos
	cmp #24
	bpl apl_leave ;in the proper zone
	sec
	sbc #24
	beq +
	cmp #$FF
	beq +
	lda #$FE		;max speed
+	clc
	adc ppx
	cmp #0
	bpl +
	dec dpx
	clc
	adc #3
+
	sta ppx
	lda dpx
	cmp #0
	bpl +
	lda #0	;max scroll
	sta dpx
	sta ppx
+	
	jmp apl_leave

apl_scroll:
	lda playerPosX
	sec
	sbc dpx
	cmp #6
	bmi -
	cmp #8
	bpl apl_scroll_left

apl_leave:
	rts


GetPlayerScrPos:
	lda playerPosX2
	lsr
	lsr
	lsr
	sta temp16
	lda playerPosX
	sec
	sbc dpx
	sta temp8
	asl
	clc
	adc temp8
	clc
	adc temp16
	sec
	sbc ppx
	rts


TestSolidBlock:	;preload X with x pos, Y with y pos
	cpy #8
	bcs tsb_done			;outside map
	ldx playerPosX
	jsr GetMapBlock
	sta last_block
	cmp #4
	beq +
	cmp #0
	bne tsb_solid2
	jmp tsb_jmp1		
+
    jsr ToutchCoin
    jmp tsb_jmp1
tsb_crumble1:

tsb_jmp1:
	lda playerPosX2
	cmp #8
	bcc tsb_done
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	jsr GetMapBlock
	sta last_block2
	cmp #4
	beq +
	cmp #0
	bne tsb_solid
	jmp tsb_done
+	jsr ToutchCoin
tsb_done:
	clc
	rts
tsb_solid:
	sec
	rts
tsb_solid2:
	tya
	clc
	adc #8
	tay
	jsr GetMapBlock
	sta last_block2
	sec
	rts

TestSolidBlockV:	;preload X with x pos, Y with y pos
	cpx #127
	bcs tsb_solid
	ldy playerPosY
	cpy #8
	bcs tsb_done			;outside map
	jsr GetMapBlock
	cmp #4
	beq +
	cmp #0
	bne tsb_solid		
	jmp tsbv_jmp1
+	jsr ToutchCoin
tsbv_jmp1:
	lda playerPosY2
	cmp #8
	bcc tsb_done
	iny
	jsr GetMapBlock
	cmp #4
	beq +
	cmp #0
	bne tsb_solid
	jmp tsb_done
+	jsr ToutchCoin
	clc
	rts

ToutchCoin:
	lda #1
	inc coinCnt
	lda #0
    sty tc_y    ;save x and y we need them
    stx tc_x
	jsr PutMapBlock

    lda coinCnt
    cmp #100
    bne +
    inc playerLives     ;gain live
    lda #0
    sta coinCnt
+
    jsr DisplayCoins
    ldy #0
tc_y = *-1
    ldx #0
tc_x = *-1
	rts


;************************************************
processPlayerDie:
    ;whait 6 cycle
    lda #6
    jsr Delay
    ;clear the place
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
    dec scr_y
	
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

    lda scr_y
	asl
	tax
	lda screenOffset,x
	sta vector1
	lda screenOffset+1,x
	sta vector1+1

    lda scr_y
    cmp #20
    bcc +
    jmp pld_outside
+

   ;draw the part 1
    lda scr_x
    clc
    adc #40
    tay
    lda #32
    sta (vector1),Y
    iny
    lda #$51
    sta (vector1),Y
    iny
    lda #32
    sta (vector1),Y
    tya
    clc
    adc #38
    tay
    lda #$51
    sta (vector1),Y
    iny
    lda #32
    sta (vector1),Y
    iny
    lda #$51
    sta (vector1),Y
    tya
    clc
    adc #38
    tay
    lda #32
    sta (vector1),Y
    iny
    lda #$51
    sta (vector1),Y
    iny
    lda #32
    sta (vector1),Y


    ;whait 3 cycle
    lda #3
    jsr Delay

    ;draw part 2
    ldy scr_x
    dey
    lda #$51
    sta (vector1),Y
    iny
    iny
    iny
    iny
    sta (vector1),Y
    tya
    clc
    adc #156
    tay
    lda #$51
    sta (vector1),Y
    iny
    iny
    iny
    iny
    sta (vector1),Y



    ;whait 3 cycles
    lda #3
    jsr Delay

    ;clear part 1
    lda scr_x
    clc
    adc #41
    tay
    lda #$20
    sta (vector1),Y
    tya
    clc
    adc #39
    tay
    lda #$20
    sta (vector1),Y
    iny
    iny
    lda #$20
    sta (vector1),Y
    tya
    clc
    adc #39
    tay
    lda #$20
    sta (vector1),Y


    ;whait
    lda #3
    jsr Delay

    ;clear part 2
    ldy scr_x
    dey
    lda #$20
    sta (vector1),Y
    iny
    iny
    iny
    iny
    sta (vector1),Y
    tya
    clc
    adc #156
    tay
    lda #$20
    sta (vector1),Y
    iny
    iny
    iny
    iny
    sta (vector1),Y

    ;whait
    lda #6
    jsr Delay

-
    ;reload map
    dec playerLives
    lda playerLives
    beq +
    jsr LoadMap
    rts

+   jsr DisplayGameOver
    lda #30
    jsr Delay

    jsr DisplayWelcomScr

	jsr NewGame
    rts

pld_outside:
    lda #12
    jsr Delay
    jmp -