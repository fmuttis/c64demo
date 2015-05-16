;256b intro rndlife 2 by terric/meta 2010-11-29 This was a tight fit!!!
;compiled with 64tass 1.46

        *=$0801
	.byte $0a,$08,$0a,$00,$9e,$32,$30,$36,$32
	.byte $00,$00,$00,$00   
	*=$080e
	sei

	lda #$11
	sta $d021
	sta $0286
	sta $d412
	jsr $e544
	lda #$00
	sta worm
	sta $d021
	sta $f8
	sta $f9	




loopa
	ldx #$00
	lda #39
	sta bound+1
	sta $d40e
	jsr movecheck
	inx
	lda #24
	sta bound+1
	sta $d40f
	jsr movecheck
	tya
	pha
	lda $f9

	sta $f0
	lda #$00
	sta $f1
	sta $f5
	sta $f6
	lda $f8
	sta $f4
	lda #$04
	sta $f7
	jsr raddlohi
	ldx worm
	lda $f0
	sta worm+1
	lda $f1
	sta worm+257
	lda $d41b
	sta worm+514
	cpx #$fd
	bcs +
	inc worm
+	

tre

	lda worm+514,x
	sta worm+515,x
	tay
	lda worm+1,x
	sta worm+2,x
	sta $fa
	sta $fc
	lda worm+257,x
	sta worm+258,x
	sta $fb
	clc
	adc #$d4
	sta $fd
	tya
	ldy #$00
	sta ($fa),y
	lda $d41b
	sta ($fc),y
	cpx #$00
	beq +
	dex
	jmp tre
+
	pla
	tay
	jmp loopa
asloop
	asl $f0,x
	rol $f1,x
	dey
	bpl asloop
	rts
addxyt
	txa
	tay
-	iny
	iny
	lda $f0,x
	clc
	adc $f0,y
	sta $f0,x
	bcc +
	inc $f1
+
	
	cpy #$06
	bcc -
	rts
raddlohi
	ldx #$00
	ldy #$02
	jsr asloop
	lda $f0
	sta $f2
	lda $f1
	sta $f3
	ldx #$00
	ldy #$01
	jsr asloop
	jsr addxyt
	inx
	jsr addxyt
	rts
movecheck
	lda $f8,x
bound	cmp #24
	beq +
	lsr $d41b
	adc #$00

+	

	cmp #$00
	beq +
	lsr $d41b
	sbc #$00
+
	sta $f8,x
	rts
worm	=*