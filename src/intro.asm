.import source "helpers.mac"
//.var music = LoadSid("../music/Slither.sid")
.var music = LoadSid("../music/Kill_You.sid")

// global variables
.var smooth1 = $02
.var smooth2 = $03
.var sync = $04 // irq quantity for processing intro
.var anim = $05


:BasicUpstart2(start)
// basicUpstart2 creates the sys command to allow running the prg. 
// it sets the sys code at $0801 ~ $080e

// setup sprites priorities/properties
//lda #$ff
//sta $d015 // all sprites on
//sta $d01c // multicolor on
//sta $d01b // behind chars

//lda #$05
//sta $d025 // spr mcolor 1
//lda #$0b
//sta $d026 // spr mcolor 2
//lda #$0d
//sta $d027 // changable colors
//sta $d028
//sta $d029
//sta $d02a
//sta $d02b
//sta $d02c
//sta $d02d
//sta $d02e

// init scroll messages
    lda #<message1
    ldx #>message1
    sta read1+1
    stx read1+2
    lda #<message2
    ldx #>message2
    sta read2+1
    stx read2+2

start:
    
    :clearScreen()

// -------------- load logo ------------------

    // load the background color from logo
    lda $4710 // logo background color value
    sta $d020
    sta $d021

    ldx #$00
copyLogoToMem:
    lda $3f40,x
    sta $0400,x
    lda $4040,x
    sta $0500,x
    lda $4140,x
    sta $0600,x
    lda $4240,x
    sta $0700,x
copyColorToMem:
    lda $8328,x
    sta $d800,x
    lda $8428,x
    sta $d900,x
    lda $8528,x
    sta $da00,x
    lda $8628,x
    sta $db00,x

    inx
    bne copyLogoToMem

// -------------- still msg ------------------
    ldx #$00
cpymsg:
    lda stillmsg, x
    sta $05e0, x
    inx
    cmp #$00  // if @ appears, then you must quit the LF from linux txt
    bne cpymsg
// -------------- still msg ------------------
 

	lda #$00
	ldx #0
	ldy #0
	lda #music.startSong-1
	jsr music.init  // jump subrutine, needs RTS to go back (music.init code has it)
                    // doesn't affect any flags

// ---------- deprecated code -------------
	// change character set
    // we won't move screen memory at $0400
    // and we'll set charset at $2000
    // in $D018 Memory setup register

    //lda #$18    // charset $2000, screen memory $0400 on...
    //sta $d018   // ...Memory setup register 
// ---------- deprecated code -------------
	
    sei // deactivate interrupts
	
    // disable NMI overwriting pointer to default routine at $FE47
    lda #<noNMI // lo
    sta $0318 
    lda #>noNMI // hi
    sta $0319   // NMI Interrupt Vector
                // Contains execution address of non-maskable interrupt service routine. 
   
    // setup interrupts (this implementation chains irqs, we setup the first one only)
    
    lda #<irq1  // low
	sta $0314
	lda #>irq1  // high
	sta $0315   // Execution address of interrupt service routine.
	
	lda #$01    // enable raster interrupt on...
	sta $d01a   // ...Interrupt control register
	lda #$1b    // Clear high bit of $d012, set text mode on ... 
	sta $d011   // ...Screen control register #1

	lda #$aa
	sta $d012   // write raster line to generate interrupt at (bits #0-#7)
                // accum contains the line which will be triggered

    lda #$7f    // ACK: disable all off... (or enable all events?)
	sta $dc0d   // ...Interrupt control and status register (CIA1/IRQ) and...
    sta $dd0d   // ...Interrupt control and status register (CIA2/NMI)

    lda $dc0d   // by reading this two registers we negate any pending CIA irqs.
    lda $dd0d   // if we don't do this, a pending CIA irq might occur after we finish setting up our irq.
                // we don't want that to happen.

    asl $d019   // ACK: VIC Interrupts

	cli         // reactivate interrupts

mainloop: 
    lda sync // initialize synchronization of irqs
    and #$00
    sta sync
syncwait:
    cmp sync
    beq syncwait
    jsr scroll1 // call scroll 1
    jsr scroll2 // call scroll 2
    jsr colwash
    jsr movepic
    jmp mainloop	// infinite loop
                // it's ok, we handle all with interrupts

noNMI:
    asl $d019   // ACK Interrupt (to re-enable it)
    rti
// ------------------------------------------------
irq1:
    inc $d019 // $d019 Bit #0: 0 = Acknowledge raster interrupt.
    lda #$86
    sta $d012 // force an interrupt in rasterline 86

    // change VIC-II bank

    .var screenChars  = $7f40 // the 40x25 buffer
    .var screenPixels = $6000 // the pixel data for font or bitmap ($1000 or $9000 are always charrom)

    // Select VIC bank
    .eval const vicBank=[[screenChars ^ $ffff] >> 14]

    lda #vicBank
    sta $dd00

    // Set VIC screen and font pointers
    .eval const vicScreenAndFont=[[[screenChars & $3fff] / $0400] << 4] + [[[screenPixels & $3fff] / $0800] << 1]
    lda #vicScreenAndFont
    sta $d018    


    ldx #$3b // bitmap mode
    stx $d011 

    lda #$00
    ldx #$02
    sta $d020
    sta $d021
    lda d016 // this represents a label!
    ora #%00001000 // set bitmap multicolor
    sta $d016


    lda #<irq2 // call irq2
    ldx #>irq2
    sta $0314
    stx $0315
    jmp $ea81

irq2:
    inc $d019
    lda #$da
    sta $d012 // split normal screen with charset at $2800

    lda #$1b
    ldx #$08
    ldy #$1a
    sta $d011
    stx $d016
    sty $d018

    // change vic-ii banks
    lda $dd00
    and #%11111100
    ora #%00000011 // xxxxxx11 means $0000 (bank 0 on vic-II)
    sta $dd00
    
    // call irq3
    lda #<irq3
    ldx #>irq3
    sta $0314
    stx $0315
    jmp $ea81
    
irq3:
    inc $d019 // split for the 1st scroll
    lda #$e6
    sta $d012
    lda #$1b
    ldx smooth1
    stx $d016
    lda #$00
    lda #<irq4
    ldx #>irq4
    sta $0314
    stx $0315
    jmp $ea81

irq4:
    inc $d019   // split 
    lda #$fa
    sta $d012
    ldx smooth2
    stx $d016
    lda #<irq1 // complete the cycle
    ldx #>irq1
    sta $0314
    stx $0315
    inc sync

    //inc $d020   // [shows] how much time takes jsr to play music in rastertime
	jsr music.play
	//dec $d020   // [shows] until here
    
    jmp $ea31

// ------------- color washing routine ------------
// this change char colors from right to left cycling in coloursN data
colwash:
    lda colours1+$00
    sta colours1+$28
    lda colours2+$00
    sta colours2+$28
    lda coloursBlackAndWhite+$00
    sta coloursBlackAndWhite+$28
    ldx #$00
wshloop:
    lda colours1+$01, x
    sta colours1+$00, x
    lda colours2+$01, x
    sta colours2+$00, x
    lda coloursBlackAndWhite+$01, x
    sta coloursBlackAndWhite+$00, x

    lda colours1+$00, x
    sta $db48, x // line of first scroller

    lda colours2+$00, x
    sta $db98, x // line of second scroller

// flash routine. remove ',x' from "lda colours", to get flashing
    lda coloursBlackAndWhite+$00 // read colours
    sta $d9e0, x // these d[NNN] are the lines of still text
    lda coloursBlackAndWhite+$00
    sta $da08, x
    lda coloursBlackAndWhite+$00
    sta $da30, x
    lda coloursBlackAndWhite+$00
    sta $da58, x
    lda coloursBlackAndWhite+$00
    sta $da80, x
    lda coloursBlackAndWhite+$00
    sta $daa8, x
    inx
    cpx #$28
    bne wshloop
    rts

// moving picture 
movepic:
    lda d016+$00
    sta d016+$49
    ldx #$00
waveloop:
    lda d016+$01, x
    sta d016+$00, x
    inx
    cpx #$49
    bne waveloop
    rts

    


// ------------- scroll1 code ------------------
scroll1:
    lda smooth1
    sec
    sbc #$02
    and #$07
    sta smooth1
    bcs endscr1
    ldx #$00
wrap:
    lda $0749, x // position of scroll + index in screen memory
    sta $0748, x // position of scroll + index in screen memory
    inx
    cpx #$28
    bne wrap
read1:
    lda $076f // the end of line in screen memory has a zero?
    cmp #$00
    bne nowrap1
    lda #<message1
    ldx #>message1
    sta read1+1
    stx read1+2
    jmp read1
nowrap1:
    sta $076f
    inc read1+1
    lda read1+1
    cmp #$00
    bne endscr1
    inc read1+2
endscr1:
    rts

scroll2:
    lda smooth2
    sec
    sbc #$03
    and #$07
    sta smooth2
    bcs endscr2
    ldx #$00
wrap2:
    lda $0799, x // position of scroll + index in screen memory
    sta $0798, x // position of scroll + index in screen memory
    inx
    cpx #$28
    bne wrap2
read2:
    lda $07bf // the end of line in screen memory has a zero? 
    cmp #$00
    bne nowrap2
    lda #<message2
    ldx #>message2
    sta read2+1
    stx read2+2
    jmp read2
nowrap2:
    sta $07bf
    inc read2+1
    lda read2+1
    cmp #$00
    bne endscr2
    inc read2+2
endscr2:
    rts



// ----------------------
.pc = music.location "Music"
.fill music.size, music.getData(i)

// ----------------------
//  character set
// ----------------------
.pc = $2800 "charset"
.import c64 "mini.64c"
//.import c64 "green_beret.64c"
//.import c64 "herobotix.64c"
//.import c64 "impossible_mission.64c"

// ----------------------
//  data 
// ----------------------
.pc = $4000 "Intro Data"
message1:
.print "importing text (message1)..."
.import text "message1.txt"
.byte $00 // \0 C simil
message2:
.print "importing text (message2)..."
.import text "message2.txt"
.byte $00 

stillmsg:
.text ".:: industria flashera incorporated ::. "
.text "  http://iflashera.pocimatoshiana.com/  "
.text "                                    "
.text "     anhos pintandole el culo a la maldad   "
.text "      1998-2012 bs as argentina" 
.text "                 ahora en commodore 64       "
.byte $00

// d016 ???
d016: .fill 64,round(12*sin(toRadians(i*360/256)))
//d016:
         .byte $00,$00,$01,$01,$02
         .byte $02,$03,$03,$04,$04
         .byte $05,$05,$06,$06,$07
         .byte $07,$06,$06,$05,$05
         .byte $04,$04,$03,$03,$02
         .byte $02,$01,$01,$00,$00
         .byte $01,$01,$01,$02,$02
         .byte $02,$03,$03,$03,$04
         .byte $04,$04,$05,$05,$05
         .byte $06,$06,$06,$07,$07
         .byte $07,$06,$06,$06,$05
         .byte $05,$05,$04,$04,$04
         .byte $03,$03,$03,$02,$02
         .byte $02,$01,$01,$01,$00
         .byte $00,$00,$00

// colorwashing colour data
colours1:
         .byte $0b,$0b,$09,$09,$02
         .byte $02,$08,$08,$0a,$0a
         .byte $0f,$0f,$07,$07,$01
         .byte $01,$01,$01,$01,$01
         .byte $07,$07,$0f,$0f,$08
         .byte $08,$02,$02,$09,$09
         .byte $0b,$0b,$0b,$0b,$0b
         .byte $0b,$0b,$0b,$0b,$0b
         .byte $00

colours2:
         .byte $0b,$0b,$0b,$0b,$06
         .byte $06,$04,$04,$0e,$0e
         .byte $05,$05,$0d,$0d,$07
         .byte $07,$01,$01,$07,$07
         .byte $0d,$0d,$0e,$0e,$04
         .byte $04,$06,$06,$0b,$0b
         .byte $0b,$0b,$0b,$0b,$0b
         .byte $0b,$0b,$0b,$0b,$0b
         .byte $00

coloursBlackAndWhite:
         .byte $00,$00,$00,$00,$0b
         .byte $0b,$0b,$0b,$0f,$0f
         .byte $0f,$0f,$0c,$0c,$0c
         .byte $0c,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01
         .byte $01,$01,$01,$0c,$0c
         .byte $0c,$0c,$0f,$0f,$0f
         .byte $0f,$0b,$0b,$0b,$0b
         .byte $00


// logo

.pc = $55fd "brx logo" // .pc equ org directive
.import c64 "brlogo.prg" // "c64" same as binary but skips frist 2 bytes (prg files has 2 bytes header)

// ----------------------
// kickassembler output 
// ----------------------

.print ""
.print "SID Data"
.print "--------"
.print "location=$"+toHexString(music.location)
.print "init=$"+toHexString(music.init)
.print "play=$"+toHexString(music.play)
.print "songs="+music.songs
.print "startSong="+music.startSong
.print "size=$"+toHexString(music.size)
.print "name="+music.name
.print "author="+music.author
.print "copyright="+music.copyright
.print ""
.print "Additional tech data"
.print "--------------------"
.print "header="+music.header
.print "header version="+music.version
.print "flags="+toBinaryString(music.flags)
.print "speed="+toBinaryString(music.speed)
.print "startpage="+music.startpage
.print "pagelength="+music.pagelength

	


