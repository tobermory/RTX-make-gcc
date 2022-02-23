#include "cmsis_os2.h"

/**
 * @author Stuart Maclean
 * 
 * A real 'power application' using an RTOS.
 */

int main(void) {

  osKernelInitialize();

  osKernelStart();
  
  return 0;
}
