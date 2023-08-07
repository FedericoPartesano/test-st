[#ftl]
/**
  ******************************************************************************
  * @file    gnss_lib_config.c
  * @author  SRA
  * @brief   Configure how the libGNSS accesses the GNSS module
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
#include "gnss_lib_config.h"
[#compress]
[#assign useCUSTOMBOARD = false]
[#assign useGNSS1A1 = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("BSP_GNSS")]
[#assign useCUSTOMBOARD = true]
[/#if]
[#if define?contains("GNSS1A1")]
[#assign useGNSS1A1 = true]
[/#if]

[/#list]
[/#if]

[/#compress]
[#if useCUSTOMBOARD]
#include "custom_gnss.h"
[/#if]
[#if useGNSS1A1]
#include "gnss1a1_gnss.h"
[/#if]

int32_t GNSS_Wrapper_Send(uint8_t *buffer, uint16_t length)
{
  int32_t status=0;
  
[#if useCUSTOMBOARD]
  CUSTOM_GNSS_Msg_t gnssMsg;
  
  gnssMsg.buf = buffer;
  gnssMsg.len = length;
  
  status = CUSTOM_GNSS_Send(CUSTOM_TESEO_LIV3F, &gnssMsg);
[#else]
[#if useGNSS1A1]
  GNSS1A1_GNSS_Msg_t gnssMsg;
  
  gnssMsg.buf = buffer;
  gnssMsg.len = length;
  
  status = GNSS1A1_GNSS_Send(GNSS1A1_TESEO_LIV3F, &gnssMsg);
[#else]
  /* USER CODE BEGIN Send */
  
  /* USER CODE END Send */
[/#if]
[/#if]
  
  return status;
}

int32_t GNSS_Wrapper_Reset(void)
{
  int32_t status=0;
  
[#if useCUSTOMBOARD]
  status = CUSTOM_GNSS_Reset(CUSTOM_TESEO_LIV3F);
[#else]
[#if useGNSS1A1]
  status = GNSS1A1_GNSS_Reset(GNSS1A1_TESEO_LIV3F);
[#else]
  /* USER CODE BEGIN Reset */
  
  /* USER CODE END Reset */
[/#if]
[/#if]

  return status;
}

void GNSS_Wrapper_Delay(uint32_t Delay)
{
[#if useCUSTOMBOARD | useGNSS1A1]
  HAL_Delay(Delay);
[#else]
  /* USER CODE BEGIN Delay */
  
  /* USER CODE END Delay */
[/#if]
}

