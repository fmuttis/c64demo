/*****************************************************************************
 * 256b Rubber Twistor
 * Code: Cruzer/CML
 * Asm'ed with: KickAss 2.25
 *****************************************************************************/
  
.var cnt =		$02
.var rubberSine =	$20

.var code =		$0801
.var sine128 =		$1000
.var sine0 =		$1400
.var sine1 =		$1500
.var sine2 =		$1600
.var d018s =		$1800
.var sprite0 =		$3000
.var sprite1 =		$3040
.var sprite2 =		$3080
.var screen0 =		$3800
.var screen1 =		$3c00

.pc = code "code"
//------------------------------------------------------------------------------
basic:			.by $0b,$08,$39,$05,$9e,$32,$30,$36,$31
zero:			.by $00,$00,$00
//------------------------------------------------------------------------------
start:
			sei

			ldx #0
			txa
			sta $3fff
			pha

//calc "sine" (or more like a set of parabolas)...

			ldy #$ff
!loop:	
loa:			lda #$18
			adc #$07
			sta loa+1
			bcc !+
			inc hia+1
			clc
!:
lo:			adc #0
			sta lo+1
			pla
hia:			adc #0
			pha
			sta sine128+$c0,x
			sta sine128-$40,y
			eor #$7f
			sta sine128+$40,x
			sta sine128-$c0,y

			inx
			dey
			cpx #$40
			bne !loop-


			ldx #0
// copy sine...
!:
			txa
			and #$40
			lsr
			lsr
			adc #$e0
			sta d018s,x
			txa
			and #$3f
			tay

			lda #%10101010
			sta sprite0-1,y
			lsr
			sta sprite1-1,y
			lda #%11111111
			sta sprite2-1,y

ls:			lda sine128+$20,y
			lsr
			adc #$60
ss:			sta sine2,x
			inx
			bne !-

			dec ss+2
			lda ls+1
			adc #$40
			sta ls+1
			bcc !-
			
			ldx #$c0
			stx $3ff8
			stx $3bf8
			inx
			stx $3ff9
			stx $3bfa
			inx
			stx $3ffa
			stx $3bf9

			ldx #$06
			stx $d027
			inx
			stx $d015
			stx $d01d
			stx $d01c

//------------------------------------------------------------------------------
mainLoop:
			inc cnt

			lda #$f8
!:			cmp $d012
			bne !-
			lda #$00
			sta $d011

			ldx #$7f
			ldy cnt
!:
			lda sine128,x
			lsr
			adc cnt
			clc
			adc sine128,y
			lsr
			adc cnt
			sta rubberSine,x
			iny
			dex
			bpl !-
			
			
			lda #$16
!:			cmp $d012
			bne !-
			
			sta $d001
			sta $d003
			sta $d005
			
			lda #$08
			sta $d011

!:			
			lda zero
			sta $d017
			dec $d017
			
			ldy rubberSine+$80,x
			
			lda d018s,y
			sta $d018
			
			lda sine0,y
			sta $d004
			lda sine1,y
			sta $d002
			lda sine2,y
			sta $d000

			dex
			bmi !-
						
			bpl mainLoop
