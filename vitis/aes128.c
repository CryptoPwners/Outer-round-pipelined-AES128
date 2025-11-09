#include <stdio.h>
#include "platform.h"
#include "sleep.h"
#include "xbasic_types.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"
Xuint32* baseaddr = (Xuint32*)0x43C00000;
int main () {
    init_platform ();
    int slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4;
    int slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9;
    int ctext_0, ctext_1, ctext_2, ctext_3, keydone, done;
    slv_reg0 = 0;
    slv_reg1 = 0;
    slv_reg2 = 0;
    slv_reg3 = 0; // plaintext
    slv_reg4 = 0;
    slv_reg5 = 0;
    slv_reg6 = 0;
    slv_reg7 = 0; // key
    slv_reg9 = 1; // rst
    print ("hello\n\r");
    Xil_Out32 ((baseaddr + 4), slv_reg4);
    Xil_Out32 ((baseaddr + 5), slv_reg5);
    Xil_Out32 ((baseaddr + 6), slv_reg6);
    Xil_Out32 ((baseaddr + 7), slv_reg7);
    Xil_Out32 ((baseaddr + 8), slv_reg8);
    slv_reg8 = 0;
    Xil_Out32 ((baseaddr + 8), slv_reg8);
    // Write plaintext registers
    Xil_Out32 ((baseaddr + 0), slv_reg0);
    Xil_Out32 ((baseaddr + 1), slv_reg1);
    Xil_Out32 ((baseaddr + 2), slv_reg2);
    Xil_Out32 ((baseaddr + 3), slv_reg3);
    Xil_Out32 ((baseaddr + 9), slv_reg9);
    slv_reg9 = 0;
    Xil_Out32 ((baseaddr + 9), slv_reg9);
    // Wait for encryption done
    while (1) {
        done = Xil_In32 (baseaddr + 15);
        if (done == 1)
            break;
    }
    // Read ciphertext
    ctext_0 = Xil_In32 ((baseaddr + 10));
    ctext_1 = Xil_In32 ((baseaddr + 11));
    ctext_2 = Xil_In32 ((baseaddr + 12));
    ctext_3 = Xil_In32 ((baseaddr + 13));
    xil_printf ("cipher_32 = %0x\n\r", ctext_0);
    xil_printf ("cipher_64 = %0x\n\r", ctext_1);
    xil_printf ("cipher_96 = %0x\n\r", ctext_2);
    xil_printf ("cipher_128 = %0x\n\r", ctext_3);
    cleanup_platform ();
    return 0;
}
