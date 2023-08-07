[#ftl]
/**
  ******************************************************************************
  * @file    stm32_bus_ex.c
  * @author  MCD Application Team
  * @brief   Source file for GNSS1A1 Bus Extension
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
/* Includes ------------------------------------------------------------------*/
#include "${BoardName}_bus.h"
#include "stm32_bus_ex.h"

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

[#if IpBusInstance != ""]
/**
  * @brief  Transmit data to the device through BUS.
  * @param  DevAddr Device address on Bus (I2C only).
  * @param  pData  Pointer to data buffer to write
  * @param  Length Data Length
  * @retval BSP status
  */
int32_t BSP_${IpBusInstance}_Send_IT(uint16_t DevAddr, uint8_t *pData, uint16_t Length)
{
  int32_t ret = BSP_ERROR_BUS_FAILURE;

[#if IpBusInstance == I2CIpInstance]
  if(HAL_${IpBusName}_Master_Transmit_IT(&h${IpBusInstance?lower_case}, (uint8_t)DevAddr,
                                         (uint8_t *)pData, Length) == HAL_OK)
[#else]
  UNUSED(DevAddr);

  if(HAL_${IpBusName}_Transmit_IT(&h${IpBusInstance?lower_case?replace("s","")}, (uint8_t *)pData, Length) == HAL_OK)
[/#if]
  {
    ret = BSP_ERROR_NONE;
  }
  else
  {
    ret =  BSP_ERROR_PERIPH_FAILURE;
  }
  return ret;
}

/**
  * @brief  Receive data from the device through BUS.
  * @param  DevAddr Device address on Bus (I2C only).
  * @param  pData Pointer to data buffer to write
  * @param  Length Data Length
  * @retval BSP status
  */
int32_t BSP_${IpBusInstance}_Recv_IT(uint16_t DevAddr, uint8_t *pData, uint16_t Length)
{
  int32_t ret = BSP_ERROR_BUS_FAILURE;
  
[#if IpBusInstance == I2CIpInstance]
  if(HAL_${IpBusName}_Master_Receive_IT(&h${IpBusInstance?lower_case}, (uint8_t)DevAddr,
                                        (uint8_t *)pData, Length) == HAL_OK)
[#else]
  UNUSED(DevAddr);

  if(HAL_${IpBusName}_Receive_IT(&h${IpBusInstance?lower_case?replace("s","")}, (uint8_t *)pData, Length) == HAL_OK)
[/#if]
  {
    ret = BSP_ERROR_NONE;
  }
  else
  {
    ret =  BSP_ERROR_PERIPH_FAILURE;
  }
  return ret;
}

[#if USARTisTrue]
#if (USE_HAL_UART_REGISTER_CALLBACKS == 1)
int32_t BSP_${IpBusInstance}_RegisterRxCallback(p${IpBusName}_CallbackTypeDef pCallback)
{
  return HAL_${IpBusName}_RegisterCallback(&h${IpBusInstance?lower_case?replace("s","")}, HAL_${IpBusName}_RX_COMPLETE_CB_ID, pCallback);
}

int32_t BSP_${IpBusInstance}_RegisterErrorCallback(p${IpBusName}_CallbackTypeDef pCallback)
{
  return HAL_${IpBusName}_RegisterCallback(&h${IpBusInstance?lower_case?replace("s","")}, HAL_${IpBusName}_ERROR_CB_ID, pCallback);
}
#endif
[/#if]

[#if I2CisTrue]
#if (USE_HAL_I2C_REGISTER_CALLBACKS == 1)
int32_t BSP_${IpBusInstance}_RegisterRxCallback(p${IpBusName}_CallbackTypeDef pCallback)
{
  while (HAL_${IpBusName}_GetState(&h${IpBusInstance?lower_case}) != HAL_${IpBusName}_STATE_READY)
  {
  }
  return HAL_${IpBusName}_RegisterCallback(&h${IpBusInstance?lower_case}, HAL_${IpBusName}_MASTER_RX_COMPLETE_CB_ID, pCallback);
}

int32_t BSP_${IpBusInstance}_RegisterErrorCallback(p${IpBusName}_CallbackTypeDef pCallback)
{
  while (HAL_${IpBusName}_GetState(&h${IpBusInstance?lower_case}) != HAL_${IpBusName}_STATE_READY)
  {
  }
  return HAL_${IpBusName}_RegisterCallback(&h${IpBusInstance?lower_case}, HAL_${IpBusName}_ERROR_CB_ID, pCallback);
}

int32_t BSP_${IpBusInstance}_RegisterAbortCallback(p${IpBusName}_CallbackTypeDef pCallback)
{
  while (HAL_${IpBusName}_GetState(&h${IpBusInstance?lower_case}) != HAL_${IpBusName}_STATE_READY)
  {
  }
  return HAL_${IpBusName}_RegisterCallback(&h${IpBusInstance?lower_case}, HAL_${IpBusName}_ABORT_CB_ID, pCallback);
}
#endif
[/#if]

[#if I2CisTrue]
void BSP_EV_${IpBusInstance}_IRQHanlder(void)
{
  HAL_${IpBusName}_EV_IRQHandler(&h${IpBusInstance?lower_case});
}

void BSP_ER_${IpBusInstance}_IRQHanlder(void)
{
  HAL_${IpBusName}_ER_IRQHandler(&h${IpBusInstance?lower_case});
}
[/#if]
[#if USARTisTrue]
void BSP_${IpBusInstance}_ClearOREF(void)
{
  __HAL_${IpBusName}_CLEAR_FLAG(&h${IpBusInstance?lower_case?replace("s","")}, UART_FLAG_ORE);
}

void BSP_${IpBusInstance}_IRQHanlder(void)
{
  HAL_${IpBusName}_IRQHandler(&h${IpBusInstance?lower_case?replace("s","")});
}
[/#if]

[/#if]

