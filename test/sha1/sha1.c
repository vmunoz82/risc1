/******************************************************
Copyright (c) 2010 Victor Munoz. All rights reserved.
derechos reservados, prohibida su reproduccion

Author: Victor Munoz
Contact: vmunoz@ingenieria-inversa.cl
******************************************************/

//#define _RISC_TESTING_

#ifndef _RISC_TESTING_
#include <stdio.h>
#endif

#define ROL32(x,n) ((x<<n) | (x>>(32-n)))

unsigned int h0,h1,h2,h3,h4;
	
void SHA1_chunk(unsigned char *buf) {
    unsigned int a,b,c,d,e,f,k,t;
    int i;
    
	unsigned int word[80];

	for(i=0; i<16; ++i) {
		word[i] = (buf[i*4+0] << 24) | (buf[i*4+1] << 16) | (buf[i*4+2] << 8) | buf[i*4+3];
	}
	for(; i<80; ++i) {
		word[i] = ROL32((word[i-3]^word[i-8]^word[i-14]^word[i-16]),1);
	}

	a=h0;
	b=h1;
	c=h2;
	d=h3;
	e=h4;

	for(i=0; i<80; ++i) {
		if(i<20) {
			f=(b&c) | ((~b) & d);
			k=0x5A827999;
		}
		else if(i<40) {
			f=b^c^d;
			k=0x6ED9EBA1;
		}
		else if(i<60) {
			f=(b&c) | (b&d) | (c&d);
			k=0x8F1BBCDC;
		} else {
			f=b^c^d;
			k=0xCA62C1D6;
		}

		t=(ROL32(a,5) + f + e + k + word[i]) & 0xFFFFFFFF;
		e=d;
		d=c;
		c=ROL32(b,30);
		b=a;
		a=t;
	}

	h0+=a;
	h1+=b;
	h2+=c;
	h3+=d;
	h4+=e;
}

void SHA1(unsigned char *str, unsigned int sz) {
    int i;
    int nsz;
    unsigned char t[64];
     
	h0 = 0x67452301;
	h1 = 0xEFCDAB89;
	h2 = 0x98BADCFE;
	h3 = 0x10325476;
	h4 = 0xC3D2E1F0;
 
    nsz=sz;
	while(nsz>=64) {
    	SHA1_chunk(str);
    	str+=64;
    	nsz-=64;
    }

    for(i=0; i<64; ++i) {
        t[i]=i<nsz?str[i]:0;
    }
    t[nsz]=0x80;
    if(nsz>55) {
        SHA1_chunk(t);
        for(i=0; i<59; ++i) t[i]=0;
    }
    t[59]=(sz>>29)&0xFF;
    t[60]=(sz>>21)&0xFF;
    t[61]=(sz>>13)&0xFF;
    t[62]=(sz>>5)&0xFF;
    t[63]=(sz<<3)&0xFF;
    SHA1_chunk(t);

}

const char vector[]="The quick brown fox jumps over the lazy dog";
int main() {
	SHA1((unsigned char *)vector, sizeof(vector)-1);
	
#ifndef _RISC_TESTING_	
	printf("sha1 digest: %08X %08X %08X %08X %08X\n", h0, h1, h2, h3, h4);
#endif

	return 0;
}
