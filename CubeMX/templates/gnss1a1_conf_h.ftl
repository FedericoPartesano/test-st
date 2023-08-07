[#ftl]
/**
  ******************************************************************************
  * @file    gnss1a1_conf.h
  * @author  SRA Application Team
  * @brief   This file contains definitions for the GNSS components bus 
  *          interface
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef GNSS1A1_CONF_H
#define GNSS1A1_CONF_H

#ifdef __cplusplus
extern "C" {
#endif

[#assign useFWUPDATER = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("FWUPD_APP")]
[#assign useFWUPDATER = true]
[/#if]

[/#list]
[/#if]

[#assign IpName =""]
[#assign IpBusName =""]
[#assign IpBusInstance =""]
[#assign I2CInstance=""]
[#assign UsartInstance=""]
[#assign IpPinInstance =""]
[#assign IpPinName =""]
[#assign RESET_PIN = ""]
[#assign RESET_PORT = ""]
[#assign WAKE_UP_PIN = ""]
[#assign WAKE_UP_PORT = ""]

[#list BspIpDatas as SWIP] 
	[#if SWIP.variables??]	
		[#list SWIP.variables as variables]
			[#if variables.name?contains("IpName")]
				[#assign IpName = variables.value]
			[/#if]
			[#if IpName == "I2C"]
				[#assign IpBusName = IpName]
				[#if variables.name?contains("IpInstance")]
					[#assign IpBusInstance = variables.value]
					[#assign I2CInstance = IpBusInstance]
				[/#if]
			[#elseif (IpName == "UART" || IpName == "USART" || IpName == "LPUART")]
				[#assign IpBusName = "UART"]
				[#if variables.name?contains("IpInstance")]
					[#assign IpBusInstance = variables.value]
					[#assign UsartInstance = IpBusInstance]
				[/#if]
			[#else]
				[#if variables.name?contains("IpInstance")]
					[#assign IpPinInstance = variables.value]
				[/#if]
				[#if variables.name?contains("IpName")]
					[#assign IpPinName = variables.value]
				[/#if]
				[#if variables.value?contains("Reset Pin")]
					[#assign RESET_PIN = IpPinInstance]
					[#assign RESET_PORT = IpPinName]
				[/#if]
				[#if variables.value?contains("Wake Up Pin")]				
					[#assign WAKE_UP_PIN = IpPinInstance]
					[#assign WAKE_UP_PORT = IpPinName]				
				[/#if]
			[/#if]
		[/#list]
	[/#if]
[/#list]

#include "${FamilyName?lower_case}xx_hal.h"
#include "${BoardName}_bus.h"
[#if !useFWUPDATER]
#include "stm32_bus_ex.h"
[/#if]
#include "${BoardName}_errno.h"

[#if IpBusInstance == I2CInstance]
#define USE_I2C 1U
[#else]
#define USE_I2C 0U
[/#if]

[#if useFWUPDATER]
[#if IpBusInstance == UsartInstance]
#define hgnss_uart h${IpBusInstance?lower_case?replace("s","")}
[#else]
#warning "FWUpdater works only using the UART as communication bus between the STM32 and the Teseo-LIV3F."
[/#if]
[/#if]


#define USE_GNSS1A1_GNSS_TESEO_LIV3F	1U

[#if IpBusInstance != ""]
#define GNSS1A1_GNSS_${IpBusName}_Init        BSP_${IpBusInstance}_Init
#define GNSS1A1_GNSS_${IpBusName}_DeInit      BSP_${IpBusInstance}_DeInit
[#if !useFWUPDATER]
#define GNSS1A1_GNSS_${IpBusName}_Transmit_IT BSP_${IpBusInstance}_Send_IT
#define GNSS1A1_GNSS_${IpBusName}_Receive_IT  BSP_${IpBusInstance}_Recv_IT
#define GNSS1A1_GNSS_GetTick         BSP_GetTick

[#if IpBusInstance == UsartInstance]
#define GNSS1A1_GNSS_${IpBusName}_ClearOREF   BSP_${IpBusInstance}_ClearOREF
[/#if]
[/#if]
[/#if]

#define GNSS1A1_RST_PORT                        ${RESET_PORT}
#define GNSS1A1_RST_PIN                         ${RESET_PIN}

#define GNSS1A1_WAKEUP_PORT                     ${WAKE_UP_PORT}
#define GNSS1A1_WAKEUP_PIN                      ${WAKE_UP_PIN}

//#define GNSS1A1_RegisterDefaultMspCallbacks     BSP_${IpBusInstance}_RegisterDefaultMspCallbacks
[#if !useFWUPDATER]
[#if IpBusInstance == I2CInstance]
#define GNSS1A1_RegisterRxCb                    BSP_${IpBusInstance}_RegisterRxCallback
#define GNSS1A1_RegisterErrorCb                 BSP_${IpBusInstance}_RegisterErrorCallback
#define GNSS1A1_RegisterAbortCb                 BSP_${IpBusInstance}_RegisterAbortCallback
[#else]
#define GNSS1A1_RegisterRxCb                    BSP_${IpBusInstance}_RegisterRxCallback
#define GNSS1A1_RegisterErrorCb                 BSP_${IpBusInstance}_RegisterErrorCallback
[/#if]
[/#if]

/* To be checked */
[#if IpBusInstance == I2CInstance]
#define GNSS1A1_${IpBusName}_EV_IRQHanlder      BSP_${IpBusInstance}_EV_IRQHanlder
#define GNSS1A1_${IpBusName}_ER_IRQHanlder      BSP_${IpBusInstance}_ER_IRQHanlder
[#else]
#define GNSS1A1_${IpBusName}_IRQHanlder                 BSP_${IpBusInstance}_IRQHanlder
[/#if]


#ifdef __cplusplus
}
#endif

#endif /* GNSS1A1_CONF_H */

