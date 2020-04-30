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

// .bss
short operandos[16];
int div_zero;
int res_zero;

// prototipos
int suma(short a, short b);
int resta(short a, short b);
int multiplica(short a, short b);
int divide(short a, short b);

// .data
typedef int (*t_operciones)(short a, short b);
t_operciones aritmaticas[4]={
    suma,
    resta,
    multiplica,
    divide
};


// .code
int suma(short a, short b) {
    return a+b;
}

int resta(short a, short b) {
    return a-b;
}

int multiplica(short a, short b) {
    int i,r,n;
    
    n=a<0&&b<0?1:0;
    
    if(n) b=-b;
    
    r=0;
    
    for(i=0; i<16; ++i) {
        if(b&1) r+=a;
        a<<=1;
        b>>=1;
    }
    
    if(n) return -r;
    return r;
}

int divide(short a, short b) {
    int i,t,r,na,nb;

    r=0;
        
    if(b==0) {
        div_zero++;
        return 0;
    }
    
    na=a<0?1:0;
    nb=b<0?1:0;
    
    if(na) a=-a;
    if(nb) b=-b;

    for(i=15; i>=0; i--) {
        t=b<<i;
        if(a>=t) {
            a-=t;
            r+=1<<i;
        }
    }

    if(na^nb) return -r;
    return r;
}

int main() {
    int i,t;
    
    div_zero=0;
    res_zero=0;
    
    // inicializa operandos
    for(i=0; i<16; ++i) operandos[i]=i+1;
    
    for(i=0; i<1000; ++i) {
        t=(*aritmaticas[operandos[(i+1)&15]&3])(operandos[operandos[(i+2)&15]&15],operandos[operandos[(i+3)&15]&15])&0xFFFF;
        if(t==0) {
            res_zero++;
            t=res_zero;
        } 
        operandos[operandos[(i+0)&15]&15]=t;
    }
#ifndef _RISC_TESTING_
    for(i=0; i<16; ++i) {
        printf("operandos[%d]: %d\n",i, operandos[i]);
    }
#endif
    return 0;
}
