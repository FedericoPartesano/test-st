[#ftl]
[#assign useCUSTOMBOARD = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("BSP_GNSS")]
[#assign useCUSTOMBOARD = true]
[/#if]

[/#list]
[/#if]

#include "${BoardName?lower_case}.h"
[#if useCUSTOMBOARD]
#include "custom_board_conf.h"
#include "custom_gnss.h"
[#else]
#include "gnss1a1_conf.h"
#include "gnss1a1_gnss.h"
[/#if]

/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private defines -----------------------------------------------------------*/
#define BUFFER_SIZE		(16)

/* Global variables ---------------------------------------------------------*/

/* Private variables ---------------------------------------------------------*/
static uint8_t fromPC[BUFFER_SIZE];
static uint8_t fromGNSS[BUFFER_SIZE];
static volatile unsigned long idxPC;
static volatile unsigned long idxGNSS;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */
