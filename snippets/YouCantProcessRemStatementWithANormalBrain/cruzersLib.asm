
.const t = true
.const f = false

.const BEQ = BEQ_REL
.const BNE = BNE_REL
.const BCS = BCS_REL
.const BCC = BCC_REL
.const BPL = BPL_REL
.const BMI = BMI_REL
.const BVS = BVS_REL
.const BVC = BVC_REL

.const KOALA_P00 = "Bitmap=$001c, ScreenRam=$1f5c, ColorRam=$2344, BackgroundColor = $272c"


// 8 bit

.pseudocommand by src;tar {
	:mb src;tar
}

.pseudocommand mb arg1;arg2 {
	lda arg1
	sta arg2
}

.pseudocommand mbd arg1;arg2;arg3 {
	lda arg1
	sta arg2
	sta arg3
}

.pseudocommand mb2 arg1;arg2 {
	lda arg1
	sta arg2
	sta arg2+1
}

/*
.pseudocommand movo offset; ptr; target {
	clc
	:add16 offset ; ptr ; tt+1
tt:	lda $1000	
	sta target
}
*/

/*
.pseudocommand jsri address {{
	.if (address.getType()==AT_INDIRECT) 
		.eval address = CmdArgument(AT_ABSOLUTE, address.getValue())
	:mov16 address ; tt+1 
tt:	jsr $1000
}}
*/

/*
.pseudocommand adc8 arg1;arg2;tar {
	.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda arg1
	adc arg2
	sta tar
}
*/

/*
.pseudocommand sbc8 arg1;arg2;tar {
	.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda arg1
	sbc arg2
	sta tar
}
*/


.function reverse(str) {
	.var reverse = ""
	.for (var i=str.size()-1; i>=0; i--) {
		.eval reverse = reverse + str.charAt(i)
	}
	.return reverse
}

.var charToColor = Hashtable()
.eval charToColor.put("0", $0)
.eval charToColor.put("1", $1)
.eval charToColor.put("2", $2)
.eval charToColor.put("3", $3)
.eval charToColor.put("4", $4)
.eval charToColor.put("5", $5)
.eval charToColor.put("6", $6)
.eval charToColor.put("7", $7)
.eval charToColor.put("8", $8)
.eval charToColor.put("9", $9)
.eval charToColor.put("a", $a)
.eval charToColor.put("b", $b)
.eval charToColor.put("c", $c)
.eval charToColor.put("d", $d)
.eval charToColor.put("e", $e)
.eval charToColor.put("f", $f)

.function toColorNybbles(str) {
	.var list = List()
	.for (var i=0; i<str.size(); i=i+2) {
		.var chr0 = str.charAt(i)
		.var color0 = charToColor.get(chr0)
		.var color1 = 0
		.if (str.size() > i+1) {
			.var chr1 = str.charAt(i+1)
			.eval color1 = charToColor.get(chr1)
		}
		.var byte = color0 << 4 | color1
		.eval list.add(byte)
	}
	.return list
}

.function toColorBytes(str) {
	.var list = List()
	.for (var i=0; i<str.size(); i++) {
		.var chr = str.charAt(i)
		.var color = charToColor.get(chr)
		.eval list.add(color)
	}
	.return list
}

.macro dumpColorNybbles(str) {
	.var colz = toColorNybbles(str)
	.fill colz.size(), colz.get(i)
}

.macro dumpNybs(str) {
	:dumpColorNybbles(str)
}
.macro dumpNybsBackw(str) {
	.eval str = reverse(str)
	:dumpNybs(str)
}

.macro dumpColorBytes(str, startWithSize) {
	.if (startWithSize == 1) {
		.by str.size()
	}
	.var colz = toColorBytes(str)
	.fill colz.size(), colz.get(i)
}

.macro colorBytesLo(str) {
	.var colz = toColorBytes(str)
	.fill colz.size(), colz.get(i)
}
.macro colorBytesHi(str) {
	.var colz = toColorBytes(str)
	.fill colz.size(), colz.get(i) << 4
}


// 16 bit

.pseudocommand wo src;tar {
	:mw src;tar
}

.pseudocommand mw src;tar {
	
	//todo: doesn't work: with (zp,x)
	
	//.print "mw: " + tar.getType()	

	lda src
	sta tar

	.var yInced = false
	
	.if (src.getType() == 6) {
		iny
		lda tar
		.eval yInced = true
	} else {
		lda _16bit_nextArgument(src)
	}

	.if (tar.getType() == 6) {
		.if (!yInced) iny
		sta tar
	} else {
		sta _16bit_nextArgument(tar)
	}
}


.pseudocommand lxy src {	
	ldx src
	ldy _16bit_nextArgument(src)
}

.pseudocommand sxy tar {	
	stx tar
	sty _16bit_nextArgument(tar)
}


//add byte
.pseudocommand ab src;tar {
	clc
	lda src
	adc tar
	sta tar
}


.pseudocommand aw adr;val {
	lda adr
	clc
	adc val
	sta adr
	lda _16bit_nextArgument(adr)
	adc _16bit_nextArgument(val)
	sta _16bit_nextArgument(adr)
}


.pseudocommand iw arg {{
	inc arg
	bne !+
	inc _16bit_nextArgument(arg)
!:
}}

.pseudocommand dw arg {
	lda arg
	bne !+
	dec _16bit_nextArgument(arg)
!:
	dec arg
}


.pseudocommand beq16 arg1; arg2; tar {
	lda arg1
	cmp arg2
	bne exit
	lda _16bit_nextArgument(arg1)
	cmp _16bit_nextArgument(arg2)
	beq tar
exit: 
}
.pseudocommand bne16 arg1; arg2; tar {
	lda arg1
	cmp arg2
	bne tar
	lda _16bit_nextArgument(arg1)
	cmp _16bit_nextArgument(arg2)
	bne tar
exit: 
}

// --------- TODO these cause weird bugs sometimes - disabled --------------

/*
	.pseudocommand bpl tar {{
		.var dist = abs(tar.getValue() - *)
		bmi !+
		jmp tar
	!:
	}}
	
	.pseudocommand bmi tar {{
		.var dist = abs(tar.getValue() - *)
		bpl !+
		jmp tar
	!:
	}}
	
	.pseudocommand bne tar {{
		//.var dist = abs(tar.getValue() - *)
	
		beq !+
		jmp tar
	!:
	}}
	
	.pseudocommand bne2 tar {{
		//.var dist = abs(tar.getValue() - *)
	
		beq !+
		jmp tar
	!:
	}}
	
	.pseudocommand beq tar {{
		.var dist = abs(tar.getValue() - *)
	
		bne !+
		jmp tar
	!:
	}}

*/

.pseudocommand loop what ; add ; to ; tar {
	lda what
	clc
	adc add
	sta what
	cmp to
	:bne tar
}

.pseudocommand addWord arg1 ; arg2 ; tar {
	.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda arg1
	adc arg2
	sta tar
	lda _16bit_nextArgument(arg1)
	adc _16bit_nextArgument(arg2)
	sta _16bit_nextArgument(tar)
}
.pseudocommand sw arg1 ; arg2 ; tar {
	.if (tar.getType()==AT_NONE) .eval arg3=arg1
	lda arg1
	sbc arg2
	sta tar
	lda _16bit_nextArgument(arg1)
	sbc _16bit_nextArgument(arg2)
	sta _16bit_nextArgument(tar)
}


.pseudocommand vicOn {
	:mb #$35; $01
	cli
}

.pseudocommand vicOff {
	sei
	:mb #$34; $01
}



//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

.function _16bit_nextArgument(arg) {
	.if (arg.getType()==AT_IMMEDIATE) .return CmdArgument(arg.getType(),>arg.getValue())
	.return CmdArgument(arg.getType(),arg.getValue()+1)
}

.function int(n) {
	.var str = "" + n
	.eval str = str.substring(0, str.size()-2)
	.return str
}

.function hex(n) {
	.return toHexString(n)
}

.function hex(n, minDigits) {
	.var str = toHexString(n)
	.for ( ;str.size() < minDigits; str="0"+str){}
	.return str
}

// gets a random int which is >=min and <=max...
//
.function rnd(min, max) {
	.var range = max - min + 1
	.return floor(random() * range) + min
}

// gets a random int which is >=min and <=max, and not 0...
//
.function rndNot0(min, max) {
	.var result = rnd(min, max)
	.if (result == 0) {
		.eval result = rndNot0(min, max)
	}
	.return result
}

// gets a List with length len containing random ints which are >=min and <=max...
//
.function rndList(len, min, max) {
	.var result = List()
	.for (var i=0; i<len; i++) {
		.eval result.add(rnd(min,max))
	}
	.return result
}


.function intListToString(intList) {
	.var result = ""
	.for (var i=0; i<intList.size(); i++) {
		.eval result = result + toIntString(intList.get(i))
		.if (i<intList.size()-1) .eval result = result + ","
	}
	.return result
}
	


.macro musicTest(initAdr, initValue, playAdr, zpFill) {
	// e.g. :musicTest(music.init, $00, music.play, $00)

	sei
	lda #zpFill
	ldx #$02
!:	sta $00,x
	inx
	bne !-

!:	sta $100,x
	inx
	bne !-
	
	ldx #$ff
	txs
	
	lda #initValue
	jsr initAdr
loop:
	lda #$73
!:	cmp $d012
	bne !-

	inc border
	jsr playAdr
	inc border
	
	:mw #$0400; !s++1
	:mw #$d800; !c++1
	ldx #$00
!yLoop:	ldy #$00
!xLoop:	
	lda $00,x
	pha
	cmp #$20
	bne !s+
	lda #$00
!s:	sta $0400,y
	pla
	cmp #zpFill
	beq !+
	cpx #$02
	bcc !+
	lda #$07
!c:	sta $d800,y
!:	inx
	iny
	cpy #$10
	bne !xLoop-
	lda !s-+1
	clc
	adc #$28
	sta !s-+1
	sta !c-+1
	lda !s-+2
	adc #$0
	sta !s-+2
	and #$03
	ora #$d8
	sta !c-+2
	cpx #$00
	bne !yLoop-
	
	inc border
	
	ldx #$00
!:	lda $100,x
	sta $06d0,x
	inx
	bne !-
	
	:by #0; border
	jmp loop

}

.macro printList(prefix, list) {
	.var out = prefix
	.for (var i=0; i<list.size(); i++) {
		.eval out = out + toIntString(list.get(i))
		.if (i < list.size()-1) .eval out = out + ","
	}
	.print out
}

.macro printHexList(prefix, list, postfix) {
	.var max = 0
	.for (var i=0; i<list.size(); i++) .eval max = max(max, list.get(i))
	.var digits = 2
	.if (max >= $100) .eval digits = 4
	.var out = prefix
	.for (var i=0; i<list.size(); i++) {
		.eval out = out + "$" + hex(list.get(i), digits)
		.if (i < list.size()-1) .eval out = out + ","
	}
	.print out + postfix
}

.function printHexList(prefix, list, postfix) {
	.var max = 0
	.for (var i=0; i<list.size(); i++) .eval max = max(max, list.get(i))
	.var digits = 2
	.if (max >= $100) .eval digits = 4
	.var out = prefix
	.for (var i=0; i<list.size(); i++) {
		.eval out = out + "$" + hex(list.get(i), digits)
		.if (i < list.size()-1) .eval out = out + ","
	}
	.print out + postfix
}

.macro printStringList(prefix, list) {
	.var out = prefix
	.for (var i=0; i<list.size(); i++) {
		.eval out = out + list.get(i)
		.if (i < list.size()-1) .eval out = out + ","
	}
	.print out
}
