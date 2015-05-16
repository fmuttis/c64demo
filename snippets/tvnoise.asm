//---------------------------------------------------------------------------------------------------------------------
// TV-Noise C64 [16:9 Edition]
//---------------------------------------------------------------------------------------------------------------------
// Code: Cruzer/CML Sports on 2010-11-14
// Asm: KickAss 3.14
//---------------------------------------------------------------------------------------------------------------------
.var randomize = false
//---------------------------------------------------------------------------------------------------------------------
.pc = $0326	//thanx to 4mat for this trick
.word start
.byte $ed,$f6
//---------------------------------------------------------------------------------------------------------------------
start:
	sei
	ldx #$ff
	stx $d015
	stx $d017
	stx $d01d
	stx $d01b
	stx $d01c
	stx $d021
	lda #$0b
	sta $d026
	ldx #$c1
	stx $fb
	stx $d025
	inx
	stx $dd00
	
.define noiseSrc0, noiseSrc1, noiseSrc2 {
	.if (randomize) {
		.var noiseSrc0 = $e000 + random()*$2000
		.var noiseSrc1 = $e000 + random()*$2000
		.var noiseSrc2 = $e000 + random()*$2000
		.print ".var noiseSrc0 = $" + toHexString(noiseSrc0)
		.print ".var noiseSrc1 = $" + toHexString(noiseSrc1)
		.print ".var noiseSrc2 = $" + toHexString(noiseSrc2)
	} else {
		.var noiseSrc0 = $e1a7
		.var noiseSrc1 = $e2c4
		.var noiseSrc2 = $f834
	}
}

!:
	eor $d012
	eor noiseSrc0,x
	eor noiseSrc1,x
	eor noiseSrc2,x
out:	sta $3f00,x
	inx
	bne !-
	inc out+2
	bpl !-
	
	stx $d020
	
	lda #$48
	ldy #$10
	ldx #$0e
!:	sta $d000,x
	pha
	tya
	sta $d001,x
	iny
	iny
	pla
	sec
	sbc #$30
	dex
	dex
	bpl !-

	lda #$f0
	sta $d000
	
	ldx #$07
!:	sta $d027,x
	dex
	bpl !-
	
	ldx #$00
!loop:	ldy #$07
	txa
sp:	sta $43f8,y
	dey
	bpl sp
	inx
	lda sp+2
	clc
	adc #$04
	sta sp+2
	bcc !loop-
//---------------------------------------------------------------------------------------------------------------------
mainLoop:
	lda #$fa
!:	cmp $d012
	bne !-
	stx $d011
	
	lda #$ff
!:	cmp $d012
	bne !-
	lda #$0b
	sta $d011

	ldx #$20
!:	cpx $d012
	bne !-
	dex
!:	cpx $d012
	bne !-


	ldy #$0a
!:	dey
	bne !-
	sty $7fff
	
	
	ldx #$2b
lineLoop:
	//44 cycles available/rasterline
	
	sta $d418

	lda #$ff
	sty $d017
	sta $d017,y
	
	sta $d016
	inc $d016

	lda $d012
	asl
	asl
xor:	eor $e080
	sta $d018
	
	inx
	bne lineLoop

	dex
	stx $7fff
	
	inc xor+1
	
	lda xor+2
	clc
	adc #$03
	ora #$e0
	sta xor+2

	ldy $d00e
	ldx #$0e
!:	lda $d000-2,x
	sta $d002-2,x
	dex
	dex
	bne !-
	sty $d000
	
	asl $fb
	txa
	rol
	ora $fb
	sta $fb
	sta $d010
	
	jmp mainLoop
//---------------------------------------------------------------------------------------------------------------------

