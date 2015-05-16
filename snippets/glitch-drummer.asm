!cpu 6510
!to "glitch-drummer.prg", cbm

; A GLITCH DEMO IN 30 BYTES
; CODE: STREETUFF OF TRSI/DSS/GNUMPF-POSSE

			*=$0326

			!word main
			!word $f6ed
main			
			sei
			lda $dc05
			bne nox
			inx
nox			sbc $d011
			sta $07e8,x
			sta $d400,x
			ora #%00110000
			sta $d000,x
			jmp main