screenOffset:
!wo $0450,$0478,$04A0,$04C8,$04F0,$0518,$0540,$0568,$0590,$05B8,$05E0,$0608,$0630,$0658,$0680,$06A8
!wo $06D0,$06F8,$0720,$0748,$0770

ScreenBase = $0400




;*******************************
; Test the timer and retrigger it if ready
;

TestTimer:
	lda $dc0d
	beq +
	lda #$ff
	sta $dc05	;set timer
	lda #$19
	sta $dc0e
	sec
	rts
+	clc
	rts
	
	
InitTimer:
	lda #$1f
	sta $dc0d
	lda #$15
	sta $dc05	;set timer
	lda #$19
	sta $dc0e
	rts



;*****************************************
; key handling code
;

RefreshKeyBuffer:
	lda #$7F
	sta $DC00
	
	ldx #0
	lda $DC01
	and #$10
	bne +
	ldx #1
+
	stx doJump
	
	
	;left right
	lda #$DF
	sta $DC00
	
	ldx #0
	lda $DC01
	and #$10
	bne +
	ldx #1
+
	stx doRight
	
	ldx #0
	lda $DC01
	and #$80
	bne +
	ldx #1
+
	stx doLeft
	

	rts



WhaitForSpace:
-	lda #$7F
	sta $DC00
	
	lda $DC01
	and #$10
	bne -
	rts