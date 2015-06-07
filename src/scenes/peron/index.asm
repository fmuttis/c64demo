//============================================================
// .efo header
//============================================================

.pc = $0

.text "EFO2"          // fileformat magic
.word prepare         // prepare routine
.word setup           // setup routine
.word interrupt       // irq handler
.word 0               // main routine
.word 0               // fadeout routine
.word 0               // cleanup routine
.word 0               // location of playroutine call

// tags
//.byt "P", $04, $07    // range of pages in use
//.byt "I",$10,$1f      // range of pages inherited
//.byt "Z",$02,$03      // range of zero-page addresses in use
//.byt "S"              // i/o safe
//.byt "X"              // avoid loading
//.byt "M",<play,>play  // install music playroutine
.byte 0                 // end-of-tags

.word load_addr

load_addr:
.import source "init.asm"
.import source "fx.asm"
.import source "main.asm"
