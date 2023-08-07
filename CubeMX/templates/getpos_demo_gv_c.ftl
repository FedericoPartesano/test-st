[#ftl]
[#assign useCUSTOMBOARD = false]
[#assign useTHREADX = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("BSP_GNSS")]
[#assign useCUSTOMBOARD = true]
[/#if]

[#if define?contains("USE_THREADX_NATIVE_API")]
[#assign useTHREADX = true]
[/#if]

[/#list]
[/#if]

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
[#if !useTHREADX]
#include "cmsis_os.h"
[/#if]
[#if useCUSTOMBOARD]
#include "custom_gnss.h"
[#else]
#include "gnss1a1_gnss.h"
[/#if]
#include "gnss_data.h"
#include "${BoardName?lower_case}.h"
[#if BoardName != "STM32L0XX"]
[#if useCUSTOMBOARD]
#include "custom_board_conf.h"
[#else]
#include "gnss1a1_conf.h"
[/#if]
#include "teseo_liv3f_conf.h"
#include "gnss_feature_cfg_data.h"
[/#if]
#include "gnss_utils.h"
[#if useTHREADX]
#include "app_azure_rtos_config.h"
[/#if]

/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private defines -----------------------------------------------------------*/
[#if useTHREADX]
#define CONSOLE_STACK_SIZE      (GNSS_THREAD_MINIMUM_STACK)
#define CONSUMER_STACK_SIZE     (GNSS_THREAD_MINIMUM_STACK)
#if (USE_I2C == 1)
  #define BACKGROUND_STACK_SIZE (GNSS_THREAD_MINIMUM_STACK)
#else
  #define BACKGROUND_STACK_SIZE 0 /* in case of USART bus, the background task is not used */
#endif /* USE_I2C */
#define SAFETY_STACK_SIZE       (GNSS_THREAD_MINIMUM_STACK)

#if (GNSS_APP_MEM_POOL_SIZE < (BACKGROUND_STACK_SIZE + CONSOLE_STACK_SIZE + CONSUMER_STACK_SIZE + SAFETY_STACK_SIZE))
  #warning "The application requires a greater GNSS_APP_MEM_POOL_SIZE!"
#endif

#define TESEO_CONSUMER_TASK_PRIORITY      1
#define TESEO_CONSOLE_TASK_PRIORITY       1
#if (USE_I2C == 1)
  #define TESEO_BACKGROUND_TASK_PRIORITY  1
#endif /* USE_I2C */
[#else]
[#if BoardName == "STM32L0XX"]
#define CONSUMER_STACK_SIZE      512
#define CONSOLE_STACK_SIZE       512
#if (USE_I2C == 1)
  #define BACKGROUND_STACK_SIZE  512
#else
  #define BACKGROUND_STACK_SIZE    0   /* in case of USART bus, the background task is not used */
#endif /* USE_I2C */
[#else]
#define CONSUMER_STACK_SIZE     1024
#define CONSOLE_STACK_SIZE      1024
#if (USE_I2C == 1)
  #define BACKGROUND_STACK_SIZE 1024
#else
  #define BACKGROUND_STACK_SIZE    0   /* in case of USART bus, the background task is not used */
#endif /* USE_I2C */
[/#if]
[/#if]

/* Global variables ----------------------------------------------------------*/
[#if BoardName != "STM32L0XX"]
[#if useTHREADX]
/* Mutex for GNSS data access */
static TX_MUTEX gnssDataMutexHandle;    
[#else]
/* Mutex for GNSS data access */
#if (osCMSIS < 0x20000U)
  osMutexId gnssDataMutexHandle;
#else
  osMutexId_t gnssDataMutexHandle;
  static osMutexAttr_t mutex_attributes = {
    .name = "dataMutex"
  };
#endif /* osCMSIS */
[/#if]
[/#if]

/* Tasks handle */
[#if useTHREADX]
TX_THREAD teseoConsumerTaskHandle;
TX_THREAD consoleParseTaskHandle;

#if (USE_I2C == 1)
  TX_THREAD backgroundTaskHandle;
#endif /* USE_I2C */
[#else]
#if (osCMSIS < 0x20000U)
  osThreadId teseoConsumerTaskHandle;
  osThreadId consoleParseTaskHandle;
#else
  osThreadId_t teseoConsumerTaskHandle;
  osThreadId_t consoleParseTaskHandle;
#endif /* osCMSIS */

#if (USE_I2C == 1)
#if (osCMSIS < 0x20000U)
  osThreadId backgroundTaskHandle;
#else
  osThreadId_t backgroundTaskHandle;
#endif /* osCMSIS */
#endif /* USE_I2C */
[/#if]

/* Private variables ---------------------------------------------------------*/
static GNSSParser_Data_t GNSSParser_Data;
[#if BoardName != "STM32L0XX"]
static int gnss_feature = 0x0;
[/#if]

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
[#if useTHREADX]
static void GNSSData_Mutex_Init(void);
static UINT Console_Parse_Task_Init(VOID *memory_ptr);
static void ConsoleRead(uint8_t *string);
static UINT Teseo_Consumer_Task_Init(VOID *memory_ptr);
#if (USE_I2C == 1)
  static UINT Background_Task_Init(VOID *memory_ptr);
#endif /* USE_I2C */
[#else]
[#if BoardName != "STM32L0XX"]
static void GNSSData_Mutex_Init(void);
static void Console_Parse_Task_Init(void);
static void ConsoleRead(uint8_t *string);
[/#if]
static void Teseo_Consumer_Task_Init(void);
#if (USE_I2C == 1)
static void Background_Task_Init(void);
#endif /* USE_I2C */
[/#if]

[#if useTHREADX]
static void TeseoConsumerTask(ULONG argument);
static void ConsoleParseTask(ULONG argument);
#if (USE_I2C == 1)
  static void BackgroundTask(ULONG argument);    
#endif /* USE_I2C */
[#else]
#if (osCMSIS < 0x20000U)
  static void TeseoConsumerTask(void const *argument);
  static void ConsoleParseTask(void const *argument);
#else
  static void TeseoConsumerTask(void *argument);
  static void ConsoleParseTask(void *argument);
#endif /* osCMSIS */
#if (USE_I2C == 1)
#if (osCMSIS < 0x20000U)
  static void BackgroundTask(void const *argument);
#else
  static void BackgroundTask(void *argument);
#endif /* osCMSIS */
#endif /* USE_I2C */

#if (osCMSIS >= 0x20000U)
  static osThreadAttr_t task_attributes = {
    .priority = (osPriority_t) osPriorityNormal
  };
#endif /* osCMSIS */
[/#if]

static int ConsoleReadable(void);

static void AppCmdProcess(char *com);
static void AppCfgMsgList(int lowMask, int highMask);

[#if BoardName != "STM32L0XX"]
#if (configUSE_FEATURE == 1)
static void AppEnFeature(char *command);
#endif /* configUSE_FEATURE */

#if (configUSE_GEOFENCE == 1)
static void AppGeofenceCfg(char *command);
#endif /* configUSE_GEOFENCE */

#if (configUSE_ODOMETER == 1)
static void AppOdometerOp(char *command);
#endif /* configUSE_ODOMETER */

#if (configUSE_DATALOG == 1)
static void AppDatalogOp(char *command);
#endif /* configUSE_DATALOG */
[/#if]

static int GetSWVerCmdIsAllowed(char* com);

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */
