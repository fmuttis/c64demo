//---------------------------------------------------------------------------------------------------------------------
// 256b scroller with 264 chars of 5-bit packed text
// code: cruzer/cml
//---------------------------------------------------------------------------------------------------------------------
.var buffer = $10
.var scrollAdr = $05e0
.var pause = $e3af
//---------------------------------------------------------------------------------------------------------------------
.pc = $0326
.word start
.byte $ed,$f6
//---------------------------------------------------------------------------------------------------------------------
.macro packText(str) {
	.for (var i=0; i<str.size(); i=i+8) {
		.for (var byteNo=0; byteNo<5; byteNo++) {
			.var res = 0
			.for (var bitNo=0; bitNo<8; bitNo++) {
				.var chrVal = 0 + str.charAt(i + 7 - bitNo)
				.if (chrVal == 0 + '.') .eval chrVal = $1e
				.if (chrVal == 0 + '@') .eval chrVal = $1f
				.eval chrVal = chrVal - 1
				.var bitVal = chrVal & [$10 >> byteNo]
				.if (bitVal != 0) .eval bitVal = 1
				.eval res = res | [bitVal << bitNo]
			}
			.by res
		}
	}
}
//---------------------------------------------------------------------------------------------------------------------
scrollText:
.print "scrollText:"+toHexString(*)
:packText(
".   .  . . ...hey hey... only a few minutes later and i have already broken my own record... now we are up to two hundred and sixtyfour chars... code by cruzer of camelot... thanx to jackasser of booze for posting the smart little depacker on csdb... okthxbai... @"
)
//---------------------------------------------------------------------------------------------------------------------
start:
.print "start:"+toHexString(*)

	sei
mainLoop:
	ldx #$07
	
	lda #$47
!loop:	cmp $d012
	bne !loop-
	
	jsr pause
	
	dex
	sax $d016
	bpl !loop-
	
	inx
!loop:	lda scrollAdr+1,x
	sta scrollAdr+0,x
	sec
	rol $d9e0,x
	inx
	bne !loop-
	
txtFetch:
	dey
	bpl !+
	ldx #5
!loop:
lst:	lda scrollText
	sta buffer-1,x
	inc lst+1
	dex
	bne !loop-
	ldy #7
!:
	txa
	ldx #4
!loop:
 	asl buffer,x
 	rol
 	dex
 	bpl !loop-

 	tax
 	inx

	cpx #$1e
	beq ld
	cpx #$1f
	bne !+
	
	lda #<scrollText
	sta lst+1
ld:	ldx #'.'
	stx $d021
!:
	stx scrollAdr+$27
	
	bne mainLoop

