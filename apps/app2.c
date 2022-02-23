#include "cmsis_os2.h"

/**
 * @author Stuart Maclean
 * 
 * Yet another real 'power application' using an RTOS.
 */

int main(void) {

  osKernelInitialize();
  
  osKernelStart();

  return 0;
}
