#include <stdio.h>

void vavel(int n,char peg1,char peg2,char peg3);
int main (){
int num ;

scanf("%d",&num);
vavel(num,'1','2','3');
printf("\n");
return 0 ;
}

void vavel(int n,char peg1,char peg2,char peg3){f
    if (n==1){
        printf("/nMove disk 1 rom peg %c to peg %c",peg1,peg3 );
        return ;
    }

vavel(n-1,peg1,peg3,peg2);
printf("/nMove disk %d from peg %c to peg %c", n, peg1,peg3);
vavel(n-1,peg2,peg1,peg3);
}