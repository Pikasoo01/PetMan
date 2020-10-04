
	jsr InitTimer
	lda #12
	sta currentStage
	lda #5
	sta playerLives

	jsr DisplayWelcomScr

	jsr NewGame
	
main:
	jsr TestTimer
	bcc main
	inc fps
	jsr RefreshKeyBuffer
	jsr ApplyPlayerLogic
	jsr MonsterLogic
	jsr DrawScreen

	lda playerPosY
	cmp #8
	bne +		;if we falled we dir
	lda #1
	sta playerDie
+
	lda map_completed
	bne main_next_lvl
	lda playerDie
	beq main
	jsr processPlayerDie
	jmp main

main_next_lvl:
	;animate it
	jsr displayMapCompleted
	inc currentStage
	lda currentStage
	cmp #max_stage
	beq +
	lda #0
	sta playerDie
	lda #5
	sta doJump
	jsr LoadMap
	jmp main

+	jsr DisplayEndGame
	lda #70
	jsr Delay
	jsr DisplayWelcomScr

	jsr NewGame
	jmp main
	
!src "gfx.asm"
!src "player.asm"
!src "monster.asm"
!src "map.asm"
	

;******************************************
NewGame:
	lda #1
	sta currentStage
	lda #5
	sta playerLives
	lda #0
	sta coinCnt
	sta playerDie
	lda #5
	sta doJump
	jsr LoadMap
	rts



;******************************************
Delay:
	pha
-
	jsr TestTimer
	bcc -
	pla
	sec
	sbc #1
	cmp #0
	bne Delay
	rts


	
!align 255, 0	
;map_ptr:
;!for pos, 0, 127 {
;				!byte <(Map_Data +(pos*8))
;			}
;!for pos, 0, 127 {
;				!byte >(Map_Data +(pos*8))
;			}

block_data:

!by 32,32,32,32,32,32,32,32,32			;empty
!by $e3,$D0,$e3,$d0,$e3,$e3,$e3,$e3,$d0	;block
!by $4F,$63,$50,$65,$5A,$67,$4C,$64,$7A	;container
!by $cf,$e3,$d0,$e5,$e0,$e7,$cC,$e4,$fA	;coin container
!by 32,32,32,$e9,$4d,32,$4d,$69,32		;coin
!by $e9,$e0,$69,$63,$63,$4f,$78,$78,$78 ;bridge
!by $20,$e9,$e0,$e0,$e0,$d5,$d5,$e0,$e0 ;water
!by $fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb	;crumble #1
!by $fb,$fb,$fb,$f9,$fb,$fb,$20,$f9,$20	;crumble #2
!by $fb,$fb,$fb,$77,$f9,$20,$20,$20,$20	;crumble #3
!by $78,$ef,$77,$20,$20,$20,$20,$20,$20	;crumble #4
!by $fc,$f8,$62,$ec,$78,$e2,$61,$20,$20	;flag
!by $d1,$d1,$d1,$20,$20,$20,$20,$20,$20	;end
!by $df,$5f,$a0,$a0,$df,$5f,$5f,$a0,$df	;pillar

sprite_data:
!by $20,$51,$20,$ff,$e0,$7f,$6c,$c2,$7b ;stand
!by $20,$51,$20,$ff,$e0,$7f,$20,$c2,$20 ;walk right
!by $20,$51,$20,$76,$ee,$7b,$6c,$e2,$7b ;walk right
!by $20,$51,$20,$ff,$e0,$7f,$20,$c2,$20 ;walk left
!by $20,$51,$20,$6c,$f0,$75,$6c,$e2,$7b ;walk left
!by $20,$51,$6c,$EC,$e0,$78,$62,$ec,$fb	;jmp right
!by $7b,$51,$20,$78,$e0,$fb,$ec,$fb,$62 ;jmp left

;crawler
!by $df,$20,$e9, $d1,$e0,$d1, $fb,$f8,$f0 
!by $df,$20,$e9, $d1,$e0,$d1, $ee,$f7,$ec 

;bee
!by $20,$69,$20, $51,$e8,$df, $27,$22,$5f	
!by $20,$40,$20, $51,$e8,$df, $27,$22,$5f

;spike
!by $20,$41,$20, $20,$42,$20, $41,$42,$41
!by $41,$20,$41, $42,$20,$42, $42,$41,$42	

;fish
!by $df,$20,$e9, $5f,$e0,$d1, $e9,$ef,$df	
!by $e9,$e1,$df, $5f,$e0,$d1, $e9,$ef,$df	

;poof
!by $51,$5d,$57, $43,$20,$43, $57,$5d,$51	
!by $51,$5d,$57, $43,$20,$43, $57,$5d,$51	



Map_Data_Ptr:
!wo map1_data
!wo map2_data
!wo map3_data
!wo map4_data
!wo map5_data
!wo map6_data
!wo map7_data
!wo map8_data
!wo lmap_data


map1_data:
!src "map\map1.asm"
map2_data:
!src "map\map2.asm"
map3_data:
!src "map\map3.asm"
map4_data:
!src "map\map4.asm"
map5_data:
!src "map\map5.asm"
map6_data:
!src "map\map6.asm"
map7_data:
!src "map\map7.asm"
map8_data:
!src "map\map8.asm"

lmap_data:
!src "map\lastmap.asm"


