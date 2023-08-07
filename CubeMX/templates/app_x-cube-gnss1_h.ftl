[#ftl]
/**
  ******************************************************************************
  * @file    app_${ModuleName?lower_case}.h
  * @author  SRA Application Team
  * @brief   Header file for app_${ModuleName?lower_case}.c
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef APP_${ModuleName?upper_case}_H
#define APP_${ModuleName?upper_case}_H

#ifdef __cplusplus
extern "C" {
#endif

[#assign useTHREADX = false]
[#assign useGETPOS = false]
[#assign useSIMOSGETPOS = false]
[#assign useVIRTUALCOMPORT = false]
[#assign useFWUPDATER = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("USE_THREADX_NATIVE_API")]
[#assign useTHREADX = true]
[/#if]

[#if define?contains("GETPOS_APP")]
[#assign useGETPOS = true]
[/#if]

[#if define?contains("SIMOSGETPOS_APP")]
[#assign useGETPOS = false]
[#assign useSIMOSGETPOS = true]
[/#if]

[#if define?contains("VCOM_APP")]
[#assign useVIRTUALCOMPORT = true]
[/#if]

[#if define?contains("FWUPD_APP")]
[#assign useFWUPDATER = true]
[/#if]

[/#list]
[/#if]
/* Includes ------------------------------------------------------------------*/
[#if useTHREADX]
#include "tx_api.h"
[/#if]

/* Exported Functions --------------------------------------------------------*/
[#if useTHREADX]
[#if useGETPOS | useVIRTUALCOMPORT]
void MX_GNSS_PreOSInit(void);
UINT MX_GNSS_Init(VOID *memory_ptr);
[/#if]
[#else]
void ${fctName}(void);
[#if useGETPOS | useVIRTUALCOMPORT]
void MX_GNSS_PreOSInit(void);
void MX_GNSS_PostOSInit(void);
[/#if]
[#if useSIMOSGETPOS | useFWUPDATER]
void ${fctProcessName}(void);
[/#if]
[/#if]

#ifdef __cplusplus
}
#endif
#endif /* APP_${ModuleName?upper_case}_H */
