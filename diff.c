#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXCHAR 5000

int main(int argc, char * argv[])
{
    char buffer0[MAXCHAR];
    char buffer1[MAXCHAR];
    int i;

    if(argc < 3) {
        fprintf(stderr, "usage: %s [FILE1] [FILE2]\n", argv[0]);
        return 1;
    }

    FILE * f0 = fopen(argv[1], "r");
    FILE * f1 = fopen(argv[2], "r");

    // discard first 3 lines
    for(i=0; i<3; i++) {
        fgets(buffer0, MAXCHAR, f0);
        fgets(buffer1, MAXCHAR, f1);
    }

    // compare dimensions

    fgets(buffer0, MAXCHAR, f0);
    fgets(buffer1, MAXCHAR, f1);

    int w = atoi(buffer0+28);
    int h = atoi(buffer1+28);

    if(strcmp(buffer0, buffer1) != 0) {
        fprintf(stderr,"error: image dimensions do not match\n");
        return 1;
    }

    fgets(buffer0, MAXCHAR, f0);
    fgets(buffer1, MAXCHAR, f1);

    if(strcmp(buffer0, buffer1) != 0) {
        fprintf(stderr,"error: image dimensions do not match\n");
        return 1;
    }

    printf("width:  %d\n", w);
    printf("height: %d\n", h);

    // discard next 10 lines
    for(i=0; i<10; i++) {
        fgets(buffer0, MAXCHAR, f0);
        fgets(buffer1, MAXCHAR, f1);
    }

    int done = 0;
    for(i = 1; i <= h; i++) {
        if(fgets(buffer0, MAXCHAR, f0) == 0) done = 1;
        if(fgets(buffer1, MAXCHAR, f1) == 0) done = 1;

        if(strcmp(buffer0, buffer1) != 0) {
            int j;
            int pp = -1;
            for(j=0; j < MAXCHAR; j++) {
                if(buffer0[j] == '\0')
                    break;
                if(buffer1[j] == '\0')
                    break;
                if(buffer0[j] != buffer1[j]) {
                    int p = j/11;
                    int c = p*11;
                    if(p == pp) {
                        continue;
                    }
                    pp = p;
                    //printf("%d, %d: %c%c %c%c %c%c ; %c%c %c%c %c%c\n",h-i,p,
                    //       buffer0[c], buffer0[c+1], buffer0[c+3], buffer0[c+4], buffer0[c+6], buffer0[c+7],
                    //       buffer1[c], buffer1[c+1], buffer1[c+3], buffer1[c+4], buffer1[c+6], buffer1[c+7]);
                    printf("[%d, %d, 0x%c%c, 0x%c%c, 0x%c%c ],\n",h-i,p,
                           buffer1[c], buffer1[c+1], buffer1[c+3], buffer1[c+4], buffer1[c+6], buffer1[c+7]);
    
                }
            }
        }

    }

    fclose(f0);
    fclose(f1);

    return 0;
}
