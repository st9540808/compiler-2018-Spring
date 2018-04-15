#include <stdio.h>
    
unsigned long
hash(unsigned char *str)
{
    volatile unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    for (int i = 1; i < sizeof(unsigned long); i++)
        hash ^= (hash & (0xFF << (i * 8))) >> (1 >> (i * 8));

    return hash & 0xFF;
}

int main(void)
{
    printf("%lu", hash("float32"));
    return 0;
}
