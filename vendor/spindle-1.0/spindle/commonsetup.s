; Spindle by lft, www.linusakesson.net/software/spindle/
; Prepare CIA #1 timer B to compensate for interrupt jitter.
; Also initialise d01a and dc02.
; This code is inlined into prgloader, and also copied into
; the first handover page by pefchain.

		ldx	$d012
		inx
resync
		cpx	$d012
		bne	*-3
		; at cycle 4 or later
		ldy	#0		; 4
		sty	$dc07		; 6
		lda	#8		; 10
		sta	$dc06		; 12
		iny			; 16
		sty	$d01a		; 18
		dey			; 22
		dey			; 24
		lda	#$11		; 26
		sta	$dc0f		; 28
		sty	$dc02		; 32
		cmp	(0,x)		; 36
		cmp	(0,x)		; 42
		cmp	(0,x)		; 48
		txa			; 54
		inx			; 56
		inx			; 58
		cmp	$d012		; 60	still on the same line?
		bne	resync
