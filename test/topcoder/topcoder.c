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

void memset2(void *b, int v, int sz) {
    while(sz--) *((unsigned char *)(b++))=v;
}

int n, ans, a[10][10], x[10], y[10], u[10];
 
int mabs(int x) {
  if (x < 0) return -x;
  else return x;
}
 
void rec(int v, int w) {
  if (w >= ans) return;
  if (v == n) {
    ans = w;
    return;
  }
  int i, j, k, ok;
  for (i=0;i<5;i++)
    for (j=0;j<5;j++) {
      if (v == 0) ok = 1; else
      if (a[i][j] == 0) {
        ok = 0;
        if (i > 0)
          if (a[i-1][j] == 1) ok = 1;
        if (j > 0)
          if (a[i][j-1] == 1) ok = 1;
        if (i < 4)
          if (a[i+1][j] == 1) ok = 1;
        if (j < 4)
          if (a[i][j+1] == 1) ok = 1;
      }
      else ok = 0;
      if (ok) {
        a[i][j] = 1;
        for (k=0;k<n;k++)
          if (!u[k]) {
            u[k] = 1;
            rec(v+1,w+mabs(x[k]-i)+mabs(y[k]-j));
            u[k] = 0;
          }
        a[i][j] = 0;
      }
    }
}
 
int getMinimumMoves(char board[5][5]) {
  int i, j;
  n = 0;
  for (i=0;i<5;i++)
    for (j=0;j<5;j++)
      if (board[i][j] == '*'){
        x[n] = i;
        y[n] = j;
        n++;
      }
  memset2(a,0,sizeof(a));
  memset2(u,0,sizeof(u));
  ans = 1000000;
  rec(0,0);
  return ans;
}
 
char boards[3][5][5]={
{".....",
 "..**.",
 ".....",
 "...*.",
 "....."},
{".....",
 ".....",
 ".**..",
 ".*...",
 "**..."},
{"*...*",
 ".....",
 ".....",
 ".....",
 "*...*"}
};
 
int r[3];
int main() {
    int i;
    for(i=0; i<3; ++i) {
        r[i]=getMinimumMoves(boards[i]);

#ifndef _RISC_TESTING_
        printf("resultado para %d: %d\n", i, r[i]);
#endif

    }
    return 0;
}
