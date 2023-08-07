[#ftl]
/**
  ******************************************************************************
  * @file    ${name}
  * @author  SRA Application Team
  * @brief   This file contains definitions for the TESEO LIV3F Component 
  *          settings
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef TESEO_LIV3F_CONF_H
#define TESEO_LIV3F_CONF_H

#ifdef __cplusplus
extern "C" {
#endif

[#compress]
[#assign useCMSIS_ITF = false]
[#assign useTHREADX = false]
[#assign useGETPOS = false]
[#assign useVIRTUALCOMPORT = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("USE_CMSIS_FREERTOS")]
[#assign useCMSIS_ITF = true]
[/#if]

[#if define?contains("USE_THREADX_NATIVE_API")]
[#assign useTHREADX = true]
[/#if]

[#if define?contains("GETPOS_APP")]
[#if define?contains("SIMOS")]
[#assign useGETPOS = false]
[#else]
[#assign useGETPOS = true]
[/#if]
[/#if]

[#if define?contains("VCOM_APP")]
[#assign useVIRTUALCOMPORT = true]
[/#if]

[/#list]
[/#if]

[#list SWIPdatas as SWIP]
[#if SWIP.defines??]
  [#list SWIP.defines as definition]
    [#assign value = definition.value]
    [#assign name = definition.name]
	
	[#if name.contains("GNSS_DEVICE")]
      [#assign DEVICE_value = value]
    [/#if]
	[#if name.contains("GNSS_DEBUG")]
      [#assign DEBUG_value = value]
    [/#if]
    [#if name.contains("TeseoIII_ODOMETER")]
      [#assign ODOMETER_value = value]
    [/#if]
    [#if name.contains("TeseoIII_GEOFENCE")]
      [#assign GEOFENCE_value = value]
    [/#if]
	[#if name.contains("TeseoIII_DATALOG")]
      [#assign DATALOG_value = value]
    [/#if]

  [/#list]
[/#if]
[/#list]
[/#compress]
/* Includes ------------------------------------------------------------------*/
#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#ifdef __GNUC__
  #ifndef __weak
    #define __weak __attribute__((weak))
  #endif
#endif

/* Defines -------------------------------------------------------------------*/
[#if useCMSIS_ITF]
#define USE_osCMSIS 1 /* Use CMSIS RTOS wrapper API */
[#else]
#define USE_osCMSIS 0 /* Do not use CMSIS RTOS wrapper API */
[/#if]

#if !(USE_osCMSIS)
  #define USE_FREE_RTOS_NATIVE_API  0 /* native FreeRTOS API (not supported at application level) */
  #if !(USE_FREE_RTOS_NATIVE_API)
[#if useTHREADX]
    #define USE_AZRTOS_NATIVE_API  1  /* native AZRTOS API */
[#else]
    #define USE_AZRTOS_NATIVE_API  0  /* native AZRTOS API */
[/#if]
  #endif /* USE_FREE_RTOS_NATIVE_API */
#endif /* USE_osCMSIS */

[#-- ####################################### --]
#define ${DEVICE_value} /* ST GNSS device: can be TESEO_LIV3F_DEVICE or TESEO_VIC3DA_DEVICE */
[#-- ################################################################# --]

[#if DEBUG_value == "1"][#-- ####################################### --]
#define GNSS_DEBUG 1 /* Debug on */
[#else][#-- ####################################### --]
#define GNSS_DEBUG 0 /* Debug off */
[/#if][#-- ################################################################# --]

[#if ODOMETER_value == "1" || GEOFENCE_value == "1" || DATALOG_value == "1"][#-- ####################################### --]
#define configUSE_FEATURE 1 /* Feature on */
[#else][#-- ####################################### --]
#define configUSE_FEATURE 0 /* Feature off */
[/#if][#-- ################################################################# --]

[#if ODOMETER_value == "1"][#-- ####################################### --]
#define configUSE_ODOMETER 1 /* Odometer on */
[#else][#-- ####################################### --]
#define configUSE_ODOMETER 0 /* Odometer off */
[/#if][#-- ################################################################# --]

[#if GEOFENCE_value == "1"][#-- ####################################### --]
#define configUSE_GEOFENCE 1 /* Geofence on */
[#else][#-- ####################################### --]
#define configUSE_GEOFENCE 0 /* Geofence off */
[/#if][#-- ################################################################# --]

[#if DATALOG_value == "1"][#-- ####################################### --]
#define configUSE_DATALOG 1 /* Datalog on */
[#else][#-- ####################################### --]
#define configUSE_DATALOG 0 /* Datalog off */
[/#if][#-- ################################################################# --]

#if (GNSS_DEBUG == 1)
  #define PRINT_DBG(pBuffer)  GNSS_PRINT(pBuffer)
#else
  #define PRINT_DBG(pBuffer)
#endif

#define PRINT_INFO(pBuffer) GNSS_PRINT(pBuffer)
#define PRINT_OUT(pBuffer)  GNSS_PRINT(pBuffer)
#define PUTC_OUT(pChar)     GNSS_PUTC(pChar)

/* Exported functions prototypes ---------------------------------------------*/
int GNSS_PRINT(char *pBuffer);
int GNSS_PUTC(char pChar);

#ifdef __cplusplus
}
#endif

#endif /* TESEO_LIV3F_CONF_H*/

