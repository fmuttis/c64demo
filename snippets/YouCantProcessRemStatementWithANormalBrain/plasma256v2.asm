//------------------------------------------------------------------------------------------------------------------------------
// 256b Dither Plasma V2
// Code: Cruzer/CML
// Asm: KickAss 3.16
//------------------------------------------------------------------------------------------------------------------------------
// change log:
// + more colors
// + asm based sine generator
// + safer code, doesn't depend as much on startup zp values
// + plasma routine 1 cycle faster/char
// - crappier chars
//------------------------------------------------------------------------------------------------------------------------------
// sorry for messy code, couldn't stop experimenting :)
//------------------------------------------------------------------------------------------------------------------------------
.import source "cruzersLib.asm"
//------------------------------------------------------------------------------------------------------------------------------
.const plasmaCnt =	$02
.const plasmaYpnt =	$06
.const yPos =		$0f
.const charBuffer =	$50
.const xPnts0 =		$10
.const xPnts1 =		$50
.const xPos =		$a8
.const tmp =		$aa

.const code =		$0801
.const screen =		$0c00
.const sine =		$1000
.const charset =	$3800

.pc = code "code"
//------------------------------------------------------------------------------------------------------------------------------
.const RANDOM = -1
.const numPalettes = 8

.var effect = 5 //set to RANDOM for random parameters

.var speed0
.var speed1
.var cycleSpeed
.var xSpread0
.var xSpread1
.var ySpread0
.var ySpread1
.var ySpread2
.var sineAmp
.var palette
.var ditherType

.if (effect == RANDOM) {
	.eval speed0 =		rndNot0(-4, 4)
	.eval speed1 =		rndNot0(-4, 4)
	.eval cycleSpeed =	rndNot0(-6, 6)
	.eval xSpread0 =	rndNot0(-7, 7)
	.eval xSpread1 =	rndNot0(-7, 7)
	.eval ySpread0 =	rndNot0(-8, 8)
	.eval ySpread1 =	rndNot0(-8, 8)
	.eval ySpread2 =	rndNot0(-12, 12)
	.eval sineAmp = 	rnd(1,2) * $40
	.eval palette = 	rnd(1,numPalettes)
	.eval ditherType =	rnd(1,4)
}
.if (effect == 1) {
	.eval speed0 =      -2
	.eval speed1 =      3
	.eval cycleSpeed =  -1
	.eval xSpread0 =    -1
	.eval xSpread1 =    -4
	.eval ySpread0 =    -4
	.eval ySpread1 =    3
	.eval ySpread2 =    7
	.eval sineAmp =     $80
	.eval palette =     1
	.eval ditherType =  1
}
.if (effect == 2) {
	.eval speed0 =      1
	.eval speed1 =      2
	.eval cycleSpeed =  -1
	.eval xSpread0 =    2
	.eval xSpread1 =    -1
	.eval ySpread0 =    -1
	.eval ySpread1 =    3
	.eval ySpread2 =    -2
	.eval sineAmp =     $80
	.eval palette =     7
	.eval ditherType =  3
}
.if (effect == 3) {
	.eval speed0 =      -1
	.eval speed1 =      3
	.eval cycleSpeed =  3
	.eval xSpread0 =    -3
	.eval xSpread1 =    1
	.eval ySpread0 =    1
	.eval ySpread1 =    -5
	.eval ySpread2 =    5
	.eval sineAmp =     $80
	.eval palette =     1
	.eval ditherType =  1
}
.if (effect == 4) {
	.eval speed0 =      1
	.eval speed1 =      1
	.eval cycleSpeed =  3
	.eval xSpread0 =    -4
	.eval xSpread1 =    2
	.eval ySpread0 =    -3
	.eval ySpread1 =    -3
	.eval ySpread2 =    6
	.eval sineAmp =     $40
	.eval palette =     1
	.eval ditherType =  2
}
.if (effect == 5) {
	.eval speed0 =      3
	.eval speed1 =      -2
	.eval cycleSpeed =  -4
	.eval xSpread0 =    2
	.eval xSpread1 =    3
	.eval ySpread0 =    5
	.eval ySpread1 =    -3
	.eval ySpread2 =    4
	.eval sineAmp =     $40
	.eval palette =     1
	.eval ditherType =  1
}
.if (effect == 6) {
	.eval speed0 =      -2
	.eval speed1 =      1
	.eval cycleSpeed =  -1
	.eval xSpread0 =    -1
	.eval xSpread1 =    -4
	.eval ySpread0 =    7
	.eval ySpread1 =    -5
	.eval ySpread2 =    -5
	.eval sineAmp =     $40
	.eval palette =     4
	.eval ditherType =  1
}
.if (effect == 7) {
	.eval speed0 =      -3
	.eval speed1 =      1
	.eval cycleSpeed =  1
	.eval xSpread0 =    7
	.eval xSpread1 =    4
	.eval ySpread0 =    4
	.eval ySpread1 =    -8
	.eval ySpread2 =    1
	.eval sineAmp =     $80
	.eval palette =     3
	.eval ditherType =  1
}
.if (effect == 8) {
	.eval speed0 =      -2
	.eval speed1 =      1
	.eval cycleSpeed =  3
	.eval xSpread0 =    3
	.eval xSpread1 =    7
	.eval ySpread0 =    -3
	.eval ySpread1 =    2
	.eval ySpread2 =    -4
	.eval sineAmp =     $80
	.eval palette =     2
	.eval ditherType =  1
}
.if (effect == 9) {
	.eval speed0 =      -3
	.eval speed1 =      -1
	.eval cycleSpeed =  4
	.eval xSpread0 =    2
	.eval xSpread1 =    -3
	.eval ySpread0 =    -8
	.eval ySpread1 =    -5
	.eval ySpread2 =    -6
	.eval sineAmp =     $40
	.eval palette =     6
	.eval ditherType =  1
}
.if (effect == 10) {
	.eval speed0 =     1
	.eval speed1 =     1
	.eval cycleSpeed = -4
	.eval xSpread0 =   -2
	.eval xSpread1 =   -1
	.eval ySpread0 =   1
	.eval ySpread1 =   -2
	.eval ySpread2 =   -2
	.eval sineAmp =     $80
	.eval palette =     7
	.eval ditherType =  1
}
.if (effect == 11) {
	.eval speed0 =      -2
	.eval speed1 =      1
	.eval cycleSpeed =  4
	.eval xSpread0 =    3
	.eval xSpread1 =    7
	.eval ySpread0 =    -3
	.eval ySpread1 =    2
	.eval ySpread2 =    -4
	.eval sineAmp =     $80
	.eval palette =     5
	.eval ditherType =  1
}
.if (effect == 12) {
	.eval speed0 =      -1
	.eval speed1 =      -2
	.eval cycleSpeed =  1
	.eval xSpread0 =    5
	.eval xSpread1 =    1
	.eval ySpread0 =    -7
	.eval ySpread1 =    2
	.eval ySpread2 =    3
	.eval sineAmp =     $40
	.eval palette =     7
	.eval ditherType =  4 //or 3
}
.if (effect == 13) {
	.eval speed0 =      1
	.eval speed1 =      -2
	.eval cycleSpeed =  -1
	.eval xSpread0 =    -2
	.eval xSpread1 =    -3
	.eval ySpread0 =    3
	.eval ySpread1 =    -3
	.eval ySpread2 =    -5
	.eval sineAmp =     $40
	.eval palette =     1
	.eval ditherType =  1
}
.if (effect == 14) {
	.eval speed0 =      4
	.eval speed1 =      -1
	.eval cycleSpeed =  4
	.eval xSpread0 =    -2
	.eval xSpread1 =    1
	.eval ySpread0 =    8
	.eval ySpread1 =    -7
	.eval ySpread2 =    3
	.eval sineAmp =     $40
	.eval palette =     4
	.eval ditherType =  2
}
.if (effect == 15) {
	.eval speed0 =      1
	.eval speed1 =      1
	.eval cycleSpeed =  -3
	.eval xSpread0 =    1
	.eval xSpread1 =    2
	.eval ySpread0 =    -3
	.eval ySpread1 =    5
	.eval ySpread2 =    -1
	.eval sineAmp =     $40
	.eval palette =     1
	.eval ditherType =  3
}
// print params so they can be copy/pasted into the code if some random ones turn out to be totally awesome...
.print ""
.print ".eval speed0 =      " + int(speed0)
.print ".eval speed1 =      " + int(speed1)
.print ".eval cycleSpeed =  " + int(cycleSpeed)
.print ".eval xSpread0 =    " + int(xSpread0)
.print ".eval xSpread1 =    " + int(xSpread1)
.print ".eval ySpread0 =    " + int(ySpread0)
.print ".eval ySpread1 =    " + int(ySpread1)
.print ".eval ySpread2 =    " + int(ySpread2)
.print ".eval sineAmp =     $" + hex(sineAmp)
.print ".eval palette =     " + int(palette)
.print ".eval ditherType =  " + int(ditherType)
.print ""
//------------------------------------------------------------------------------------------------------------------------------
:BasicUpstart($080d)
//------------------------------------------------------------------------------------------------------------------------------
//clear screen to set d800-colors...
	
	lda #$00
	pha
	.if (palette == 1) {
		lda #$5b
		sta $d011
		lda #$0a
		sta $d024
		asl
		sta $0286
		jsr $e544
	}
	.if (palette == 2) {
		sta $0286
		jsr $e544
	}
	.if (palette == 3) {
		asl $0286
		jsr $e544
	}
	.if (palette == 4) {
		dec $0286
		jsr $e544
	}
	.if (palette == 5) {
		lda #$02
		sta $0286
		jsr $e544
	}
	.if (palette == 6) {
		lda #$06
		sta $0286
		jsr $e544
	}
	.if (palette == 7) {
		ldx #1
	}
	.if (palette == 8) {
		ldx #1
	}
	
	.if (ditherType != 4) {
		sei
	}
	
	//axy=d8,01,84
	
	.if (palette == 2) {
		sty $d022
		iny
		sty $d024
		lda #$5b
		sta $d011
	}
	.if (palette == 3) {
		sta $d024
		lda #$5b
		sta $d011
	}
	.if (palette == 4) {
		iny
		sty $d021
		sty $d023
		stx $d024
	}
	
//generate pseudo sine...

.var loStart
.var loAddAdd
.if (sineAmp == $40) {
	.eval loStart = $1c
	.eval loAddAdd = $03
}
.if (sineAmp == $80) {
	.eval loStart = $18
	.eval loAddAdd = $07
}

	ldy #$40
!loop:
loAdd:	lda #loStart
	adc #loAddAdd
	sta loAdd+1
	bcc !+
	inc hiAdd+1
	clc
!:
lo:	adc #$00
	sta lo+1
	pla
	.if (ditherType == 1 || ditherType == 2 || ditherType == 3) {
		sax charBuffer-$39,y	//clear charBuffer
	}
hiAdd:	adc #$00
	pha
	sta sine-1,x
	sta sine+$bf,y
	eor #sineAmp - 1
	sta sine+$80-1,x
	sta sine-$80+$bf,y
	
	.if (ditherType == 4) {
		lda #$aa
		sta charBuffer-$39,y	//clear charBuffer
	}
	inx
	dey
	bne !loop-
	

	.if (palette == 1) {
		sty $d020
	}
	.if (palette == 2) {
		sty $d020
	}
	.if (palette == 3) {
		sty $d020
	}
	.if (palette == 4) {
		sty $d020
	}

	.if (sineAmp == $80 && ditherType != 4) {
		sty charBuffer+1
	}

//generate chars...
	
.if (ditherType == 1 || ditherType == 2 || ditherType == 3) {
loop:	
	ldx #$07
	
	.if (palette == 3) {
		stx $d022
	}
	
	lda yPos
	.if (ditherType == 1) {
		sbc #0
		bpl !+
	}
	.if (ditherType == 2) {
		sbc #0
		bpl !+
	}
	.if (ditherType == 3) {
		sbc #2
		bmi !+
	}
	dec xPos
!:	sax yPos

!:	lda charBuffer,x
	sta charset + $100,y
	eor #$ff
	sta charset + $000,y
	lda sine + $000,y
	sta sine + $100,y
	iny
	beq done
	dex
	bpl !-

	.if (ditherType == 1) {
		lda xPos
	}
	.if (ditherType == 2) {
		lda yPos
		eor xPos
	}
	.if (ditherType == 3) {
		lda yPos
		eor xPos
	}
	anc #$03
	tax

	lda pixels,x
	ldx yPos
	ora charBuffer,x
	sta charBuffer,x
	
	bne loop
done:
}

.if (ditherType == 4) {
loop:
	lda xPos
	lsr
	bcc skipStore
	
	ldx #7
!:
	lda charBuffer,x
	sta charset + $080,y
	lsr
	eor #$ff
	sta charset - $080,y
	sta charset + $180,y
	
	lda sine + $000,y
	sta sine + $100,y
	
	iny
	beq done
	dex
	bpl !-
	
skipStore:
	lda xPos
	sbc #2
	and #3
	sta xPos
	tax
	
	bcs !+
	lda yPos
	sbc #2
	and #$07
	sta yPos
!:
	lda pixels,x
	ldx yPos
	eor charBuffer,x
	sta charBuffer,x
	
	jmp loop
done:
}
//------------------------------------------------------------------------------------------------------------------------------
mainLoop:
	:mb #>screen; !ss+ +2
	
	ldx #3
!:	lda plasmaCnt,x
	clc
	adc speeds,x
	sta plasmaCnt,x
	sta plasmaYpnt,x
	stx !ss+ +1
	.if (palette == 5) {
		asl $d020,x
	}
	.if (palette == 6) {
		asl $d020,x
	}
	dex
	bpl !-

	.if (palette == 1) {
		ldx #$3e
		stx $d018
		stx $d022
	}
	.if (palette == 2) {
		ldx #$3e
		stx $d018
	}
	.if (palette == 3) {
		ldx #$3e
		stx $d018
	}
	.if (palette == 4) {
		ldx #$5b
		stx $d011
		ldx #$3e
		stx $d018
	}
	.if (palette == 5) {
		ldx #$5a
		stx $d022
		stx $d024
		inx
		stx $d011
		ldx #$3e
		stx $d018
	}
	.if (palette == 6) {
		ldx #$5b
		stx $d011
		ldx #$3e
		stx $d022
		stx $d024
		stx $d018
	}
	.if (palette == 7) {
		ldx #$5b
		stx $d011
		stx $d023
		ldx #$3e
		stx $d018
	}
	.if (palette == 8) {
		ldx #$3e
		stx $d018
	}
	
	//lda plasmaCnt+0
	ldy plasmaCnt+1
!initLoop:
	clc
	adc #xSpread0
	sta xPnts0,x
	tya
	clc
	adc #xSpread1
	sta xPnts1,x
	tay
	lda xPnts0,x
	dex
	bpl !initLoop-

!yLoop:
	ldx #2
!:	lda plasmaYpnt,x
	pha
	clc
	adc ySpreads,x
	sta plasmaYpnt,x
	dex
	bpl !-
			
	pla
	sta ls+1
	pla
	sta as+1
//	pla
			
	ldx #$27
!xLoop:	
	ldy xPnts0,x
ls:	lda sine,y
	ldy xPnts1,x
as:	adc sine,y
	adc plasmaYpnt+2
	.if (palette == 8) {
		anc #$3f
	}
!ss:	sta screen,x
	dex
	bpl !xLoop-
	
	clc
	lda !ss- +1
	adc #40
	sta !ss- +1
	bcc !+
	inc !ss- +2
!:
	cmp #<[screen+40*25] //#$e8
	bne !yLoop-
	
	beq mainLoop

speeds:	.byte speed0, speed1, cycleSpeed
ySpreads:	.byte ySpread0, ySpread1, ySpread2

pixels:
.if (ditherType == 1) {
	.by %00010010
	.by %10000100
	.by %01001000
	.by %00100001
}
.if (ditherType == 2) {
	.by %00010010
	.by %10000100
	.by %01001000
	.by %00100001
}
.if (ditherType == 3) {
	.by %01000100
	.by %00010001
	.by %10001000
	.by %00100010
}
.if (ditherType == 4) {
	.by %10000000
	.by %00100000
	.by %00001000
	.by %00000010
}

