screenOffset:
!wo $8050,$8078,$80A0,$80C8,$80F0,$8118,$8140,$8168,$8190,$81B8,$81E0,$8208,$8230,$8258,$8280,$82A8
!wo $82D0,$82F8,$8320,$8348,$8370

ScreenBase = $8000


;*******************************
; Test the timer and retrigger it if ready
;

TestTimer:
	lda 59469
	and #64
	cmp #0
	beq +
	lda #$ff
	ldx #0
	sta 59461	;set timer
	stx 59469	;reset irq flag
	sec
	rts
+	clc
	rts
	
	
InitTimer:
	lda #0
	sta 59467
	sei
	lda #12
	sta 59468
	rts


;*****************************************
; key handling code
;

RefreshKeyBuffer:
	lda #$ff
rkb_type = *-1
	beq RefreshKeyBuffer2
	lda #$8
	sta $E810
	
	ldx #0
	lda $E812
	and #$4
	bne +
	ldx #1
+
	stx doJump
	
	
	;left right
	lda #$7
	sta $E810
	
	ldx #0
	lda $E812
	and #16
	bne +
	ldx #1
+
	stx doLeft
	
	lda #$6
	sta $E810
	ldx #0
	lda $E812
	and #16
	bne +
	ldx #1
+
	stx doRight
	rts


RefreshKeyBuffer2:
	ldx #0
	lda #$9
	sta $E810

	lda $E812
	and #$4
	bne +
	ldx #1
+
	stx doJump
	
	
	;left right
	lda #$9
	sta $E810
	
	ldx #0
	lda $E812
	and #64
	bne +
	ldx #1
+
	stx doRight
	
	lda #$8
	sta $E810
	ldx #0
	lda $E812
	and #64
	bne +
	ldx #1
+
	stx doLeft
	rts





WhaitForSpace:
	lda #$8
	sta $E810
	
	ldx #0
	lda $E812
	and #$4
	bne +
	rts
+
	lda #$9
	sta $E810

	lda $E812
	and #$4
	bne WhaitForSpace
	lda #0
	sta rkb_type	;this flag the kb type
	rts