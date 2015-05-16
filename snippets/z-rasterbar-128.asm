	!cpu 6510
	!to "z-rasterbar-128.prg",cbm

	table = $20

	* = $0326
	!word start
	!word $f6ed

start
	sei
	!byte $a7, $02 ; lax $02 -> lda #$00 : ldx #$00
	tay
	sta $d011

; Generate Perspective Table
-	tya
	sta table,x
	adc $02
	tay
	pla
	adc #$40 : step1 = *-1
	pha
	bcc +
	iny
+	lda step1
	adc #$0b
	sta step1
	bcc +
	inc $02
+	inx
	bne -

; Main Loop
main
	ldx #$00	
	ldy #100
-	sty $f0
	ldy table,x
	tya
	adc $03
	lsr
	lsr
	lsr
	lsr
	tay
	lda colors,y
	bcs +
	lsr
	lsr
	lsr
	lsr
+	sta $0a00,x
	ldy $f0
	sta $0a00+100,y
	inx
	dey
	bne -

	inc $03

	ldy $06
	ldx $fa
-	lda $0a00,x
	cpy $d012
	bne *-3
	sta $d020
	iny
	dex
	cpx $bf
	bne -

	txa
	beq main
	
	dec $bf
	dec $06
	inc $fa
	bne main

colors
	!byte $6b,$4e,$3d,$71,$7d,$3e,$4b,$60
	!byte $b9,$28,$af,$71,$7f,$a8,$29,$b0
