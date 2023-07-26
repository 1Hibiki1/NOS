void puts(char* str);
void putlong(long i);
void puthex(unsigned long x);

unsigned int pos;

void stage3_start() {
    pos = 5;
    puts("henlo wrld!!! c:");
    putlong(696969);
    puthex(0xDEADDEAD);

    for(;;)
        asm("hlt");
}

/* ---------------------------- screen functions ---------------------------- */
/* reverse a string in place */
void reverse_str(char str[], int len) {
    int start = 0;
    int end = len - 1;
    while (start < end) {
        char temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
}

void long_to_str(long num, char str[], int base) {
    /* Check for valid base (2 to 36 are supported) */
    if (base < 2 || base > 36) {
        return;
    }

    /* Initialize variables */
    int is_negative = 0;
    int i = 0;

    /* Handle negative numbers */
    if (num < 0 && base == 10) {
        is_negative = 1;
        num = -num;
    }

    /* Convert the number to the specified base */
    while (num != 0) {
        int remainder = num % base;
        str[i++] = (remainder < 10) ? remainder + '0' : remainder + 'A' - 10;
        num = num / base;
    }

    /* For the special case of 0 */
    if (i == 0)
        str[i++] = '0';

    /* Add negative sign if necessary */
    if (is_negative)
        str[i++] = '-';

    str[i] = '\0'; /* Null-terminate the string */

    /* Reverse the string to get the correct representation */
    reverse_str(str, i);
}

void puts(char* str) {
    char* FB = (char*)(0xb8000);
    FB += 2*pos;
    int ctr = 0;
    while(str[ctr] != 0) {
        *(FB + 2*ctr) = str[ctr];
        ctr++; pos++;
    }
}

void putlong(long i) {
    char i_str[30];
    long_to_str(i, i_str, 10);
    puts(i_str); 
}

void puthex(unsigned long x) {
    char x_str[30];
    long_to_str(x, x_str, 16);
    puts(x_str); 
}
/* -------------------------------------------------------------------------- */
