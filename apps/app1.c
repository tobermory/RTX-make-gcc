#include "cmsis_os2.h"

int main(void) {

  osKernelInitialize();

  osKernelStart();
  
  return 0;
}
