[#ftl]
/**
  ******************************************************************************
  * @file    app_${ModuleName?lower_case}.c
  * @author  SRA Application Team
  * @brief   GNSS initialization and applicative code
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n

/* Includes ------------------------------------------------------------------*/  
#include "app_${ModuleName?lower_case}.h"

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

[#if useGETPOS]
[@common.optinclude name=mxTmpFolder + "/getpos_demo_gv.tmp"/]
[/#if]

[#if useSIMOSGETPOS]
[@common.optinclude name=mxTmpFolder + "/simosgetpos_demo_gv.tmp"/]
[/#if]

[#if useVIRTUALCOMPORT]
[@common.optinclude name=mxTmpFolder + "/virtual_com_port_gv.tmp"/]
[/#if]

[#if useFWUPDATER]
[@common.optinclude name=mxTmpFolder + "/fw_updater_gv.tmp"/]
[/#if]

[#if useTHREADX]
void MX_GNSS_PreOSInit(void)
[#else]
void ${fctName}(void)
[/#if]
{
  /* USER CODE BEGIN GNSS_Init_PreTreatment */
  
  /* USER CODE END GNSS_Init_PreTreatment */
 
[#if useGETPOS]  
[@common.optinclude name=mxTmpFolder + "/getpos_demo_init.tmp"/]
[/#if]

[#if useSIMOSGETPOS] 
  /* Initialize the peripherals and the teseo device */  
[@common.optinclude name=mxTmpFolder + "/simosgetpos_demo_init.tmp"/]
[/#if]

[#if useVIRTUALCOMPORT]
[@common.optinclude name=mxTmpFolder + "/virtual_com_port_init.tmp"/]
[/#if]

[#if useFWUPDATER]
[@common.optinclude name=mxTmpFolder + "/fw_updater_init.tmp"/]
[/#if]
  
  /* USER CODE BEGIN GNSS_Init_PostTreatment */
  
  /* USER CODE END GNSS_Init_PostTreatment */
}

[#if useSIMOSGETPOS | useFWUPDATER]
void ${fctProcessName}(void)
{
  /* USER CODE BEGIN GNSS_Process_PreTreatment */
  
  /* USER CODE END GNSS_Process_PreTreatment */  
[#if useSIMOSGETPOS]
[#-- SimOSGetPos Code Begin--]
  MX_SimOSGetPos_Process();
[#-- SimOSGetPos Code End--]
[/#if]
	
[#if useFWUPDATER]
[#-- FWUpdater Code Begin--]
[@common.optinclude name=mxTmpFolder + "/fw_updater.tmp"/]
[#-- FWUpdater Code End--]
[/#if]
	
  /* USER CODE BEGIN GNSS_Process_PostTreatment */
  
  /* USER CODE END GNSS_Process_PostTreatment */
}
[/#if]

[#if useGETPOS]
[#-- GetPos Code Begin--]
[@common.optinclude name=mxTmpFolder + "/getpos_demo.tmp"/]
[#-- GetPos Code End--]
[/#if]

[#if useSIMOSGETPOS]
[#-- SimOSGetPos Code Begin--]
[@common.optinclude name=mxTmpFolder + "/simosgetpos_demo.tmp"/]
[#-- SimOSGetPos Code End--]
[/#if]

[#if useVIRTUALCOMPORT]
[#-- VirtualCOMPort Code Begin--]
[@common.optinclude name=mxTmpFolder + "/virtual_com_port.tmp"/]
[#-- VirtualCOMPort Code End--]
[/#if]

[#if useGETPOS | useSIMOSGETPOS | useVIRTUALCOMPORT | useFWUPDATER]
int GNSS_PRINT(char *pBuffer)
{
  if (HAL_UART_Transmit(&hcom_uart[COM1], (uint8_t*)pBuffer, (uint16_t)strlen((char *)pBuffer), 1000) != HAL_OK)
  {
    return 1;
  }
  fflush(stdout);

  return 0;
}

int GNSS_PUTC(char pChar)
{
  if (HAL_UART_Transmit(&hcom_uart[COM1], (uint8_t*)&pChar, 1, 1000) != HAL_OK)
  {
    return 1;
  }
  fflush(stdout);

  return 0;
}
[/#if]

