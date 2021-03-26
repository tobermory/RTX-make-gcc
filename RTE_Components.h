#ifndef _MY_RTE_COMPONENTS_H
#define _MY_RTE_COMPONENTS_H

/**
 * @author Stuart Maclean.
 *
 * Just enough of an RTE_Components.h so that we can build RTX from
 * source.
 */

// Found these in ARM docs, not sure they influence much..
#define RTE_CMSIS_RTOS                  /* CMSIS-RTOS */
#define RTE_CMSIS_RTOS_RTX5             /* CMSIS-RTOS Keil RTX5 */

// Event Recorder is a Keil-MDK thing, we don't need
#ifndef EVR_RTX_DISABLE
#define EVR_RTX_DISABLE
#endif

#endif

// eof
