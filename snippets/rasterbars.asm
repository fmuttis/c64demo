//making simple rasterbars
//by Knoeki of Digital Sounds System
//
//was coded and proven to work in Turbo Assembler 5.2 (Cyberpunx RR)
//
//should be compatible with most assemblers out there..
//
//                                                          enjoy //)



.pc=$0801

         sei              //disable interrupts

         lda #$00         //load $00 into A
         sta $d011        //turn off screen. (now you have only borders!)
         sta $d020        //make border black.

main:    ldy #$7a         //load $7a into Y. this is the line where our rasterbar will start.
         ldx #$00         //load $00 into X
loop:    lda colors,x     //load value at label 'colors' plus x into a. if we don't add x, only the first 
                          //value from our color-table will be read.

         cpy $d012        //ComPare current value in Y with the current rasterposition.
         bne *-3          //is the value of Y not equal to current rasterposition? then jump back 3 bytes (to cpy).

         sta $d020        //if it IS equal, store the current value of A (a color of our rasterbar)
                          //into the bordercolour

         cpx #51          //compare X to #51 (decimal). have we had all lines of our bar yet?
         beq main         //Branch if EQual. if yes, jump to main.

         inx              //increase X. so now we're gonna read the next color out of the table.
         iny              //increase Y. go to the next rasterline.

         jmp loop         //jump to loop.


colors:
         .byte $06,$06,$06,$0e,$06,$0e
         .byte $0e,$06,$0e,$0e,$0e,$03
         .byte $0e,$03,$03,$0e,$03,$03
         .byte $03,$01,$03,$01,$01,$03
         .byte $01,$01,$01,$03,$01,$01
         .byte $03,$01,$03,$03,$03,$0e
         .byte $03,$03,$0e,$03,$0e,$0e
         .byte $0e,$06,$0e,$0e,$06,$0e
         .byte $06,$06,$06,$00,$00,$00

         .byte $ff




//-----------------------------------------------------------------
//
//if everything goes correctly, you should have a blue rasterbar on
//the middle of your screen. play with the values a bit, and see
//what you can do with it... =)
