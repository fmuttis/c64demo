;-----------------------------------------------------
; rasterbar dream series #1 : horisontal raster lines
; by mr. rasterblaster			     15-04'10
;-----------------------------------------------------

; short info:
;
; fullscreen rasterlines takes care of $d012 and bit 8 in $d011
; using blankscreen(bit 4 in $d011) to bordercolor ($d020).
; timed by the pal-system (63 cycles per rasterline) hence,
; no interrupts used.
;
	*=$0801
	.byte $0c,$08,$01,$00,$9e,$20,$32,$30,$36,$34,$00

	*=$0810
	sei		;2	;forbid interrupts
start
	inc $4200	;6	;waste 6 cycles
	lda #$00	;2
	sta $d011	;4	clear vic-control register
loop
	lda colors,y	;4+	load colortable+offset into accumulator
	sta $d020	;4	bordercolor
	iny		;2
	adc $44		;3	;waste 3 cycles

	;check if we need to reset palette-index
	tya		;2
	cmp #$40	;2
			;= 17
	bne screen	;2+	if the palette not equal to $40 jump to screen
	;reset the palette index
	ldy #$00	;2	;
	adc $44		;3	;waste 5 cycles
screen
	;check if we are on the lower part of the screen i.e if bit 8 is set on register $d011
	lda $d011	;4
	and #%10000000	;2
	cmp #$80	;2
	beq lower_part	;2+	if bit 8 is set, branch to lower-part

	;if we are on the higher part of the screen
	inc $4200	;6	;
	inc $4200	;6	;
	nop		;2	waste 14 cycles
	tya		;2	transfer y to accumulator
	beq zero	;2+	branch to zero if accumulator (y) is zero
	nop		;2	;
	adc $44		;3	waste 5 cycles

zero
	adc $44		;3	
	nop		;2	
	nop		;2	waste 7 cycles
	jmp loop	;3	jump to loop

lower_part
	;check if we are on the last line
	tya		;2	transfer y to accumulator
	beq zero2	;2+	branch to zero2 if accumulator (y) is zero
	nop		;2	;waste 5 cycles
	adc $44		;3	;
zero2
	lda $d012	;4
	cmp #$37	;2
	beq last_line	;2+	branch to last_line if $d012 is equal to $37
	inc $4200	;6	;waste 12 cycles
	inc $4200	;6	;
	jmp loop	;3	jump to loop

last_line
	inx		;2	increment color offset
	txa		;2	set accumulator = x
	and #$3f	;2	wrap accumulator with maximum color-values
	tay		;2	set y = accumulator
	adc $44		;3	waste 3 cycles
	jmp loop	;3	jump to loop

colors
	.byte $00,$06,$0e,$06,$0e,$0e,$03,$0e
	.byte $03,$03,$01,$03,$01,$01,$03,$01
	.byte $03,$03,$0e,$03,$0e,$0e,$06,$0e
	.byte $06,$00			;blue
	
	.byte $00,$09,$08,$09,$08,$08,$07,$08
	.byte $07,$07,$01,$07,$01,$01,$07,$01
	.byte $07,$07,$08,$07,$08,$08,$09,$08
	.byte $09,$00			;brown
	
	.byte $00,$0b,$0c,$0b,$0c,$0b,$0b,$0c
	.byte $0b,$0c,$0b,$00		;gray
