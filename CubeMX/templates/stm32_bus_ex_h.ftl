[#ftl]
/**
  ******************************************************************************
  * @file    stm32_bus_ex.h
  * @author  MCD Application Team
  * @brief   Header file for stm32_bus_ex.c
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef STM32_BUS_EX_H
#define STM32_BUS_EX_H

#ifdef __cplusplus
 extern "C" {
#endif

[#assign bspName=""]
[#assign IpName =""]
[#assign IpBusName =""]
[#assign IpBusInstance =""]
[#assign I2CisTrue = false]
[#assign USARTisTrue = false]
[#assign I2CIpInstance=""]
[#assign UsartIpInstance=""]

[#list BspIpDatas as SWIP]
    [#if SWIP.bsp??]
        [#list SWIP.bsp as bsp]
            [#assign bspName = bsp.bspName]
            [#assign IpName = bsp.bspIpName]
            [#if bspName?contains("Bus_TeseoIII") || bspName?contains("Bus_Custom")]
                [#switch IpName]
                [#case "I2C"]
                    [#assign IpBusName = "I2C"]
                    [#assign I2CisTrue = true]
                    [#assign I2CIpInstance = bsp.solution]
                    [#assign IpBusInstance = bsp.solution]
                [#break]
                [#case "UART"]
                    [#assign IpBusName = "UART"]
                    [#assign USARTisTrue = true]
                    [#assign UsartIpInstance = bsp.solution]
                    [#assign IpBusInstance = bsp.solution]
                [#break]
                [#case "USART"]
                    [#assign IpBusName = "UART"]
                    [#assign USARTisTrue = true]
                    [#assign UsartIpInstance = bsp.solution]
                    [#assign IpBusInstance = bsp.solution]
                [#break]
                [#case "LPUART"]
                    [#assign IpBusName = "UART"]
                    [#assign USARTisTrue = true]
                    [#assign UsartIpInstance = bsp.solution]
                    [#assign IpBusInstance = bsp.solution]
                [#break]
                [/#switch]
            [/#if]
        [/#list]
    [/#if]
[/#list]

[#assign useGETPOS = false]
[#assign useSIMOSGETPOS = false]
[#assign useVIRTUALCOMPORT = false]
[#assign useFWUPDATER = false]

[#if RTEdatas??]
[#list RTEdatas as define]

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
#include "${BoardName}_conf.h"
#include "${BoardName}_errno.h"
[#if useGETPOS | useSIMOSGETPOS | useVIRTUALCOMPORT | useFWUPDATER]
#include "${BoardName}.h"
[/#if]
	
/* Defines -------------------------------------------------------------------*/
[#if IpBusInstance != ""]

[#if IpBusInstance == I2CIpInstance]
#define BUS_${IpBusInstance}_EV_IRQn        ${IpBusInstance}_EV_IRQn
#define BUS_${IpBusInstance}_ER_IRQn        ${IpBusInstance}_ER_IRQn
[#else]
#define BUS_${IpBusInstance}_IRQn           ${IpBusInstance}_IRQn
[/#if]

int32_t BSP_${IpBusInstance}_Send_IT(uint16_t DevAddr, uint8_t *pData, uint16_t Length);
int32_t BSP_${IpBusInstance}_Recv_IT(uint16_t DevAddr, uint8_t *pData, uint16_t Length);
[#if USARTisTrue]
#if (USE_HAL_UART_REGISTER_CALLBACKS == 1)
int32_t BSP_${IpBusInstance}_RegisterRxCallback(p${IpBusName}_CallbackTypeDef pCallback);
int32_t BSP_${IpBusInstance}_RegisterErrorCallback(p${IpBusName}_CallbackTypeDef pCallback);
#endif
[/#if]
[#if I2CisTrue]
#if (USE_HAL_I2C_REGISTER_CALLBACKS == 1)
int32_t BSP_${IpBusInstance}_RegisterRxCallback(p${IpBusName}_CallbackTypeDef pCallback);
int32_t BSP_${IpBusInstance}_RegisterErrorCallback(p${IpBusName}_CallbackTypeDef pCallback);
int32_t BSP_${IpBusInstance}_RegisterAbortCallback(p${IpBusName}_CallbackTypeDef pCallback);
#endif
[/#if]

[#if IpBusInstance == I2CIpInstance]
void BSP_EV_${IpBusInstance}_IRQHanlder(void);
void BSP_ER_${IpBusInstance}_IRQHanlder(void);
[#else]
void BSP_${IpBusInstance}_ClearOREF(void);
void BSP_${IpBusInstance}_IRQHanlder(void);
[/#if]

[/#if]

#ifdef __cplusplus
}
#endif

#endif /* STM32_BUS_EX_H */

