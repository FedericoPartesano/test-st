[#ftl]
/**
  ******************************************************************************
  * @file    ${name}
  * @author  SRA Application Team
  * @brief   This file contains application specific utilities
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef _GNSS_UTILS_H_
#define _GNSS_UTILS_H_

#ifdef __cplusplus
 extern "C" {
#endif

/** @addtogroup PROJECTS
 * @{
 */
 
/** @addtogroup APPLICATIONS
 * @{
 */
 
/** @addtogroup GetPos
 * @{
 */
		
/** @addtogroup GetPos_PUBLIC_FUNCTIONS
 * @{
 */
/**
 * @brief  This function prints to console the command menu.
 * @param  None
 * @retval None
 */
void showCmds(void);

/**
 * @brief  This function prints to console the prompt character.
 * @param  None
 * @retval None
 */
void showPrompt(void);

/**
 * @brief  This function prints to console the help.
 * @param  None
 * @retval None
 */
void printHelp(void);

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


#endif /* _GNSS_UTILS_H_ */
