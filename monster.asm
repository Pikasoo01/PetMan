;*************************************************************************
; monster motion
MonsterLogic:
	ldx #0
-	lda monsters_px,X
	cmp #128
	bcs ml_skip1	;skip if not on map
	sec
	sbc playerPosX
	clc
	adc #15
	cmp #30
	bcs ml_skip1	;not in player range
	;ok we process it
	txa
	pha
	lda monsters_px,X
	sta monster_px
	lda monsters_px2,X
	sta monster_px2
	lda monsters_py,X
	sta monster_py
	lda monsters_py2,X
	sta monster_py2
	lda monsters_dir,X
	sta monster_dir
	lda monsters_spd,X
	sta monster_spd
	lda monsters_type,X
	sta monster_type
	cmp #0
	bne +
	jsr move_crawler
	jmp ml_monst_test
+   cmp #1
	bne +
	jsr move_bee
	jmp ml_monst_test
+   cmp #3
	bne +
	jsr move_fish
	jmp ml_monst_test
+   cmp #4
	bne ml_monst_test
	jsr tick_death

ml_monst_test:
	jsr PlayerMonsterHitTest

	;jsr DrawMonster

	pla
	tax
	lda monster_px
	sta monsters_px,X
	lda monster_px2
	sta monsters_px2,X
	lda monster_py
	sta monsters_py,X
	lda monster_py2
	sta monsters_py2,X
	lda monster_dir
	sta monsters_dir,X
	lda monster_spd
	sta monsters_spd,X
	
	lda monster_type
	sta monsters_type,X

ml_skip1:	
	inx
	cpx #16
	bne -
	rts


tick_death:
	lda monster_spd
	bne +
	lda #$F0			;make it vanish
	sta monster_px
+	dec monster_spd
	rts


;crawler
move_crawler:
	lda monster_dir
	beq mv_cr_right
	sec
	lda monster_px2
	sbc #4
	sta monster_px2
	bcs +
	dec monster_px
	clc
	adc #24
	sta monster_px2
	ldx monster_px
	jsr Mst_TestSolidBlockV
	bcc +
	;hit a wall
	inc monster_px
	lda #0
	sta monster_px2
	sta monster_dir
+	jmp mv_cr_fall
mv_cr_right:
	clc
	lda monster_px2
	adc #4
	sta monster_px2
	cmp #24
	bmi +
	inc monster_px
	sec
	sbc #24
	sta monster_px2
	ldx monster_px
	inx
	jsr Mst_TestSolidBlockV
	bcc +
	;hit a wall
	lda #0
	sta monster_px2
	lda #1
	sta monster_dir
+
mv_cr_fall:
	;do we fall?
	ldy monster_py
	iny
	jsr Mst_TestSolidBlock
	bcs +
		;we fall
	inc monster_py
    cmp #8
    bcc +
    lda #$F0        ;droped in abyss
    sta monster_px
+
	rts

;bee
move_bee:
	
	lda monster_spd
	lsr
	tax
	lda monster_dir
	bne mvbe_goright
	lda monster_px2
	sec
	sbc bee_motion_x,X
	sta monster_px2
	cmp #24
	bcc +
	;change cell
	clc
	adc #24
	sta monster_px2
	dec monster_px
+	jmp mvbe_doy

mvbe_goright:
	lda monster_px2
	clc
	adc bee_motion_x,X
	sta monster_px2
	cmp #24
	bcc +
	;change cell
	sec
	sbc #24
	sta monster_px2
	inc monster_px
+

mvbe_doy:
	lda monster_py2
	clc
	adc bee_motion_y,x
	sta monster_py2


	;manage motion pointer
	inc monster_spd
	lda monster_spd
	cmp #24
	bne +
	lda #0				;start again the other way
	sta monster_spd
	lda monster_dir
	eor #1
	sta monster_dir
+	rts


bee_motion_x: !by 1,2,3,5,6,6,6,6,5,3,2,1
bee_motion_y: !by 4,4,4,-4,-4,-4,4,4,4,-4,-4,-4



;Fish motion

move_fish:
	
	lda monster_dir
	beq mvfs_goup
	dec monster_spd
	lda monster_spd
	lsr
	tax
	lda monster_py2
	clc
	adc fish_motion,X
	sta monster_py2
	cmp #24
	bcc +
	;change cell
	sec
	sbc #24
	sta monster_py2
	inc monster_py
+	lda monster_spd
	bne +
	sta monster_dir
+	rts

mvfs_goup:
	lda monster_spd
	lsr
	tax
	lda monster_py2
	sec
	sbc fish_motion,X
	sta monster_py2
	cmp #24
	bcc +
	;change cell
	clc
	adc #24
	sta monster_py2
	dec monster_py
+	inc monster_spd
	lda monster_spd
	cmp #23
	bne +
	sta monster_dir
+	rts

fish_motion: !by 1,1,1,16,16,16,12,10,8,6,4,2,1


Mst_TestSolidBlock:	;preload X with x pos, Y with y pos
	cpy #8
	bcs +			;outside map
	ldx monster_px
	jsr GetMapBlock
	cmp #4
	beq mtsb_jmp1
	cmp #0
	bne mtsb_solid	
mtsb_jmp1:	
	lda monster_px2
	cmp #8
	bcc +
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	jsr GetMapBlock
	cmp #4
	beq +
	cmp #0
	bne mtsb_solid
+	
	clc
	rts
mtsb_solid:
	sec
	rts

Mst_TestSolidBlockV:	;preload X with x pos, Y with y pos
	cpx #127
	bcs mtsb_solid
	ldy monster_py
	cpy #8
	bcs +			;outside map
	jsr GetMapBlock
	cmp #4
	beq mtsbv_jmp1
	cmp #0
	bne mtsb_solid	
mtsbv_jmp1:	
	lda monster_py2
	cmp #8
	bcc +
	iny
	jsr GetMapBlock
	cmp #4
	beq +
	cmp #0
	bne mtsb_solid
+	
	clc
	rts


;***********************************************
; Test if player toutch monster
PlayerMonsterHitTest:
    lda playerDie
    beq +
    rts
+	lda playerPosX			;6
	clc
	adc #1
	sec
	sbc monster_px			;5
	cmp #3
	bcs +		;not same zone?
	sta temp8
	asl
	clc
	adc temp8		
	sta temp8							;6

	lda monster_px2
	lsr
	lsr
	lsr
	sta temp16
	lda playerPosX2			;8
	lsr
	lsr
	lsr
	sec
	sbc temp16			;16

	sec
	sbc #1
	clc
	adc temp8
	cmp #5
	bcs +

	;right on X
	lda playerPosY			;7
	clc
	adc #1
	sec
	sbc monster_py			;8
	cmp #3
	bcs +		;not same zone?
	sta temp8
	asl
	clc
	adc temp8
	sta temp8
	lda monster_py2
	lsr
	lsr
	lsr
	sta temp16
	lda playerPosY2			;8
	lsr
	lsr
	lsr
	sec
	sbc temp16			;16
	sec
	sbc #1
	clc
	adc temp8
	tax
	cmp #5
	bcs +

	;right on it

	lda #1
	sta playerDie
	lda monster_type
    cmp #4
    bne pmht_j1
    dec playerDie
pmht_j1:
	cmp #2
	bcs +	;if deadly enemy
	cpx #2
	bcs +	;yup player die
    lda jmpPhase
	bne +
	;lda jmpCnt
	;beq +
		;we r falling
	dec playerDie
	lda #1
	sta jmpPhase		;make u bounce
	lda #4
	sta monster_type	;make it die
	sta monster_spd
	lda doJump
	bne +
	lsr jmpForce	;half bounce

+ 	rts
