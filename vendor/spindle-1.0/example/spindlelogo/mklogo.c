// This is an example effect bundled with Spindle
// http://www.linusakesson.net/software/spindle/
// Feel free to display the Spindle logo in your own demo, if you like.

#include <err.h>
#include <stdint.h>
#include <stdio.h>

uint8_t vm[25][40];

#define TOPROW 10
#define LEFTCOL 6

char *spindle[] = {
	".............................****...............................",
	"........................*********...............................",
	".....................************...............................",
	"....................*************..........***..................",
	"....................*************.........*****.................",
	"....................*************........********...............",
	"...................**************......***********..............",
	"...................**************.....*************.............",
	"...................**************....****************...........",
	"..........*........**************...******************..........",
	".........***.......**************...*******************.........",
	"........*****.....***************..*******************..........",
	"........******....***************..******************...........",
	".......********...***************..*****************............",
	"......**********...**************..****************.............",
	".....************..**************..***************..............",
	".....*************..*************.***************...............",
	"....***************..************.**************................",
	"...*****************..***********.*************...***...........",
	"...******************..**********.************..**********......",
	"...*******************.**********.***********..**************...",
	"....*******************.*********.**********..****************..",
	".....*******************.********.*********..*****************..",
	"......*******************.*******.********.*******************..",
	"......********************.******.*******.*********************.",
	".......********************.*****.******.**********************.",
	"........********************.****.*****.***********************.",
	".........********************.***.****.************************.",
	"...........*******************.**.***.*************************.",
	"................***************.*.**.***************************",
	"..................................*.****************************",
	"******************************.....*****************************",
	"*****************************.....******************************",
	"****************************.S..................................",
	"***************************.SS.*.***************................",
	".*************************.SSS.**.*******************...........",
	".************************.SSSS.***.********************.........",
	".***********************.SSSSS.****.********************........",
	".**********************.SSSSSS.*****.********************.......",
	".*********************.SSSSSSS.******.********************......",
	"..*******************.SSSSSSSS.*******.*******************......",
	"..*****************..SSSSSSSSS.********.*******************.....",
	"..****************..SSSSSSSSSS.*********.*******************....",
	"...**************..SSSSSSSSSSS.**********.*******************...",
	"......**********..SSSSSSSSSSSS.**********..******************...",
	"...........***...SSSSSSSSSSSSS.***********..*****************...",
	"................SSSSSSSSSSSSSS.************..***************....",
	"...............SSSSSSSSSSSSSSS.*************..*************.....",
	"..............SSSSSSSSSSSSSSS..**************..************.....",
	".............SSSSSSSSSSSSSSSS..**************...**********......",
	"............SSSSSSSSSSSSSSSSS..***************...********.......",
	"...........SSSSSSSSSSSSSSSSSS..***************....******........",
	"..........SSSSSSSSSSSSSSSSSSS..***************.....*****........",
	".........SSSSSSSSSSSSSSSSSSS...**************.......***.........",
	"..........TTTTTTTTTTTTTTTTTT...**************........*..........",
	"...........TTTTTTTTTTTTTTTT....**************...................",
	".............TTTTTTTTTTTTT.....**************...................",
	"..............TTTTTTTTTTT......**************...................",
	"...............TTTTTTTT........*************....................",
	".................TTTTT.........*************....................",
	"..................TTT..........*************....................",
	"...............................************.....................",
	"...............................*********........................",
	"...............................****.............................",
};

int spritecoord[2][2] = {
	{9, 33},
	{9, 54}
};

char *letterpart[] = {
	".******.",
	".******.",
	".******.",
	".******.",
	".******.",
	".******.",
	".******.",
	".******.",

	"........",
	"********",
	"********",
	"********",
	"********",
	"********",
	"********",
	"........",

	".******.",
	".*******",
	".*******",
	".*******",
	".*******",
	".*******",
	".*******",
	".******.",

	".******.",
	"*******.",
	"*******.",
	"*******.",
	"*******.",
	"*******.",
	"*******.",
	".******.",

	"........",
	".....***",
	"...*****",
	"..******",
	"..******",
	".*******",
	".*******",
	".*******",

	"........",
	"****....",
	"*****...",
	"******..",
	"******..",
	"*******.",
	"*******.",
	"*******.",

	".*******",
	".*******",
	".*******",
	"..******",
	"..******",
	"...*****",
	".....***",
	"........",

	"*******.",
	"*******.",
	"*******.",
	"******..",
	"******..",
	"*****...",
	"***.....",
	"........",

	"........",
	"........",
	"..****..",
	".******.",
	".******.",
	".******.",
	".******.",
	".******.",

	".******.",
	".******.",
	".******.",
	".******.",
	".******.",
	"..****..",
	"........",
	"........",

	"........",
	"******..",
	"*******.",
	"*******.",
	"*******.",
	"*******.",
	"******..",
	"........",

	"........",
	"..****..",
	".******.",
	".******.",
	".******.",
	".******.",
	"..****..",
	"........",
};

char *logoref = "|-><abcdTBR*";

char *logotext[] = {
	"......*.....TT....",
	"a-ba-bTa-ba-<|.a-b",
	"|..|.|||.||.||.|.|",
	"c-b|.|||.||.||.>-d",
	"..||.|||.||.||.|..",
	"c-d>-dBB.Bc-dcRc-d",
	"...B..............",
};

char *basefont[] = {
	"........",
	".*****..",
	"**...**.",
	"*******.",
	"**...**.",
	"**...**.",
	"**...**.",
	"........",

	"........",
	"*****...",
	".**.**..",
	".*****..",
	".**..**.",
	".**..**.",
	"******..",
	"........",

	"........",
	".***....",
	"**.**...",
	"**......",
	"**......",
	"**...**.",
	".*****..",
	"........",

	"........",
	"******..",
	".**..**.",
	".**..**.",
	".**..**.",
	".**..**.",
	"******..",
	"........",

	"........",
	"******..",
	"**...*..",
	"****....",
	"**......",
	"**....*.",
	"*******.",
	"........",

	"........",
	"*******.",
	"**......",
	"****....",
	"**......",
	"**......",
	"**......",
	"........",

	"........",
	".*****..",
	"**......",
	"**..***.",
	"**...**.",
	"**...**.",
	".******.",
	"........",

	".....**.",
	"**...**.",
	"**...**.",
	"*******.",
	"**...**.",
	"**...**.",
	"**...**.",
	"........",

	"........",
	".****...",
	"..**....",
	"..**....",
	"..**....",
	"..**....",
	"******..",
	"........",

	"........",
	"...****.",
	"....**..",
	"....**..",
	"....**..",
	"**..**..",
	".****...",
	"........",

	".....**.",
	"**..**..",
	"**.**...",
	"****....",
	"**.**...",
	"**..**..",
	"**...**.",
	"........",

	"........",
	"****....",
	".**.....",
	".**.....",
	".**.....",
	".**..**.",
	"*******.",
	"........",

	"........",
	"**...**.",
	"***.***.",
	"*******.",
	"**.*.**.",
	"**...**.",
	"**...**.",
	"........",

	"........",
	"**...**.",
	"***..**.",
	"****.**.",
	"**.****.",
	"**..***.",
	"**...**.",
	"........",

	"........",
	".*****..",
	"**...**.",
	"**...**.",
	"**...**.",
	"**...**.",
	".*****..",
	"........",

	"........",
	"******..",
	".**..**.",
	".*****..",
	".**.....",
	".**.....",
	".**.....",
	"........",

	"........",
	".*****..",
	"**...**.",
	"**...**.",
	"**.****.",
	"**..***.",
	".*******",
	"........",

	"........",
	"******..",
	".**..**.",
	".*****..",
	".****...",
	".**.**..",
	".**..**.",
	"........",

	"........",
	".****...",
	"**......",
	".*****..",
	".....**.",
	"**...**.",
	".*****..",
	"........",

	"........",
	"******..",
	"..**....",
	"..**....",
	"..**....",
	"..**....",
	"..**....",
	"........",

	".....**.",
	"**...**.",
	"**...**.",
	"**...**.",
	"**...**.",
	"**...**.",
	".*****..",
	"........",

	".....**.",
	"**...**.",
	"**...**.",
	"**...**.",
	".**.**..",
	".**.**..",
	"..***...",
	"........",

	".....**.",
	"**...**.",
	"**...**.",
	"**.*.**.",
	"*******.",
	"***.***.",
	"**...**.",
	"........",

	"......**",
	"**...**.",
	".**.**..",
	"..***...",
	"..***...",
	".**.**..",
	"**...**.",
	"........",

	".....**.",
	"**...**.",
	"**...**.",
	".*****..",
	"...**...",
	"...**...",
	"..****..",
	"........",

	"........",
	".******.",
	".*...**.",
	"....**..",
	"..**....",
	"**....*.",
	"*******.",
	"........",
};

char *tagline = "THE TRACKMO LOADER";

int main() {
	int i, x, y, xx, yy;
	int acc;

	for(y = 0; y < 8; y++) {
		for(x = 0; x < 8; x++) {
			vm[y + TOPROW][x + LEFTCOL] = y * 8 + x;
			for(yy = 0; yy < 8; yy++) {
				acc = 0;
				for(xx = 0; xx < 8; xx++) {
					acc <<= 1;
					if(spindle[y * 8 + yy][x * 8 + xx] == '*') {
						acc |= 1;
					}
				}
				fputc(acc, stdout);
			}
		}
	}

	for(i = 0; i < 26; i++) {
		for(yy = 0; yy < 8; yy++) {
			acc = 0;
			for(xx = 0; xx < 8; xx++) {
				acc <<= 1;
				if(basefont[i * 8 + yy][xx] == '*') acc |= 1;
			}
			fputc(acc, stdout);
		}
	}

	for(i = 0; i < 12; i++) {
		for(yy = 0; yy < 8; yy++) {
			acc = 0;
			for(xx = 0; xx < 8; xx++) {
				acc <<= 1;
				if(letterpart[i * 8 + yy][xx] == '*') acc |= 1;
			}
			fputc(acc, stdout);
		}
	}

	for(y = 0; y < 7; y++) {
		for(x = 0; x < 18; x++) {
			if(logotext[y][x] != '.') {
				for(i = 0; logoref[i]; i++) {
					if(logoref[i] == logotext[y][x]) break;
				}
				if(!logoref[i]) {
					errx(1, "Unknown char %c", logotext[y][x]);
				}
				vm[y + TOPROW][x + LEFTCOL + 9] = 64 + 26 + i;
			}
		}
	}

	for(i = 0; tagline[i]; i++) {
		if(tagline[i] != ' ') {
			vm[TOPROW + 7][i + LEFTCOL + 9] = 64 + (tagline[i] - 'A');
		}
	}

	for(i = 0; i < 1024 - 128 - 8 * (64 + 12 + 26); i++) {
		fputc(0, stdout);
	}

	for(i = 0; i < 2; i++) {
		for(y = 0; y < 21; y++) {
			for(x = 0; x < 3; x++) {
				acc = 0;
				if(spritecoord[i][1] + y < 64) {
					for(xx = 0; xx < 8; xx++) {
						acc <<= 1;
						if(spindle[spritecoord[i][1] + y][spritecoord[i][0] + x * 8 + xx] == 'S' + i) {
							acc |= 1;
						}
					}
				}
				fputc(acc, stdout);
			}
		}
		fputc(0, stdout);
	}

	fwrite(vm, 1000, 1, stdout);

	for(i = 0; i < 16; i++) {
		fputc(0, stdout);
	}

	fputc(0x8e, stdout);
	fputc(0x8f, stdout);

	for(i = 0; i < 8 - 2; i++) {
		fputc(0, stdout);
	}

	return 0;
}