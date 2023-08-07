[#ftl]
/**
  ******************************************************************************
  * @file    gnss_lib_config.h
  * @author  SRA
  * @brief   Header file for gnss_lib_config.c
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef GNSS_LIB_CONFIG_H
#define GNSS_LIB_CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif
[#compress]
[#assign useGETPOS = false]
[#assign useVIRTUALCOMPORT = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("GETPOS_APP")]
[#assign useGETPOS = true]
[/#if]

[#if define?contains("SIMOSGETPOS_APP")]
[#assign useGETPOS = false]
[/#if]

[#if define?contains("VCOM_APP")]
[#assign useVIRTUALCOMPORT = true]
[/#if]

[/#list]
[/#if]

[/#compress]
/* Includes ------------------------------------------------------------------*/
#include <stdint.h>

#include "teseo_liv3f_conf.h"
[#if useGETPOS==true || useVIRTUALCOMPORT == true]
#if (USE_FREE_RTOS_NATIVE_API) /* native FreeRTOS API */
  #include "FreeRTOS.h"
  #include "task.h"
  #define OS_Delay(a) vTaskDelay(a)
#else  
#if (USE_AZRTOS_NATIVE_API) /* native AZRTOS API */
  #include "tx_api.h"
  #define OS_Delay(a) tx_thread_sleep(a)
#else  
#if (USE_osCMSIS) /* CMSIS RTOS wrapper API */
  #include "cmsis_os.h"
  #define OS_Delay osDelay
#endif /* USE_osCMSIS */
#endif /* USE_AZRTOS_NATIVE_API */
#endif /* USE_FREE_RTOS_NATIVE_API */
[#else]
#define OS_Delay GNSS_Wrapper_Delay
[/#if]

/** @addtogroup MIDDLEWARES
 *  @{
 */

/** @addtogroup ST
 *  @{
 */

/** @addtogroup LIB_GNSS
 *  @{
 */
 
/** @addtogroup LibGNSS
 *  @{
 */
 
/** @defgroup GNSS_DATA_FUNCTIONS GNSS DATA FUNCTIONS
 *  @brief Prototypes of the API allowing the application to interface the driver
 *  and interact with GNSS module (sending commands, retrieving parsed NMEA info, etc.).
 *  The implementation is up to the application according to specific needs.
 *  @{
 */

/* Exported functions prototypes ---------------------------------------------*/
/**	
 * @brief  This function puts a string on the console (via UART).
 * @param  pBuffer The string that contains the data to be written on the console
 * @retval None
 */
int32_t GNSS_Wrapper_Send(uint8_t *buffer, uint16_t length);
int32_t GNSS_Wrapper_Reset(void);
void    GNSS_Wrapper_Delay(uint32_t Delay);

/**
 * @}
 */

/**
 * @}
 */
  
/**
 * @}
 */
  
/**
 * @}
 */ 

/**
 * @}
 */

#ifdef __cplusplus
}
#endif

#endif /* GNSS_LIB_CONFIG_H */

