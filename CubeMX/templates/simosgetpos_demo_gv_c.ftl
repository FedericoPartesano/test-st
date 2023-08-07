[#ftl]
[#assign useCUSTOMBOARD = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("BSP_GNSS")]
[#assign useCUSTOMBOARD = true]
[/#if]

[/#list]
[/#if]
/* Includes ------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

[#if useCUSTOMBOARD]
#include "custom_board_conf.h"
[#else]
#include "gnss1a1_conf.h"
[/#if]
#include "teseo_liv3f_conf.h"

[#if useCUSTOMBOARD]
#include "custom_gnss.h"
[#else]
#include "gnss1a1_gnss.h"
[/#if]
#include "gnss_data.h"
#include "${BoardName?lower_case}.h"
#include "gnss_feature_cfg_data.h"

/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private defines -----------------------------------------------------------*/

/* Global variables ----------------------------------------------------------*/

/* Instance of GNSS Handler */

/* Private variables ---------------------------------------------------------*/
static GNSSParser_Data_t GNSSParser_Data;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
static void MX_SimOSGetPos_Process(void);

#if (configUSE_FEATURE == 1)
static void AppCfgMsgList(int lowMask, int highMask);
static void AppGeofenceCfg(char *command);
static void AppEnFeature(char *command);
#endif /* configUSE_FEATURE */

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */
