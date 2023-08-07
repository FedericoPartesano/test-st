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
[#if useTHREADX]
UINT MX_GNSS_Init(VOID *memory_ptr)
{
  UINT ret = TX_SUCCESS;

  /* USER CODE BEGIN MX_GNSS_Init */
  
  /* USER CODE END MX_GNSS_Init */
  
  /* Initialize the tasks */
  ret = Console_Parse_Task_Init(memory_ptr);
  if (ret != TX_SUCCESS) {
    return ret;
  }
#if (USE_I2C == 1)
  ret = Background_Task_Init(memory_ptr);
  if (ret != TX_SUCCESS) {
    return ret;
  }
#endif /* USE_I2C */
  ret = Teseo_Consumer_Task_Init(memory_ptr);
  if (ret != TX_SUCCESS) {
    return ret;
  }

  PRINT_DBG("Booting...\r\n");
  return ret;
}
[/#if]

[#if !useTHREADX]
void MX_GNSS_PreOSInit(void)
{
  /* USER CODE BEGIN GNSS_PreOSInit */

  /* USER CODE END GNSS_PreOSInit */
}

void MX_GNSS_PostOSInit(void)
{
  /* USER CODE BEGIN GNSS_PostOSInit_PreTreatment */

  /* USER CODE END GNSS_PostOSInit_PreTreatment */
  
  /* Initialize the tasks */
  Console_Parse_Task_Init();
#if (USE_I2C == 1)
  Background_Task_Init();
#endif /* USE_I2C */
  Teseo_Consumer_Task_Init();
  
  PRINT_DBG("Booting...\r\n");
  
  /* USER CODE BEGIN GNSS_PostOSInit_PostTreatment */

  /* USER CODE END GNSS_PostOSInit_PostTreatment */
}
[/#if]

/*
 * This function creates the task reading the messages coming from Teseo 
 */
[#if useTHREADX]
static UINT Teseo_Consumer_Task_Init(VOID *memory_ptr)
[#else]
static void Teseo_Consumer_Task_Init(void)
[/#if]
{
[#if useTHREADX]
  TX_BYTE_POOL *byte_pool = (TX_BYTE_POOL*)memory_ptr;
  UINT ret = TX_SUCCESS;
  CHAR *pointer;
  
  UINT teseo_consumer_task_preemption_th = TESEO_CONSUMER_TASK_PRIORITY;

  ret = tx_byte_allocate(byte_pool, (VOID **)&pointer, CONSUMER_STACK_SIZE, TX_NO_WAIT);
  if (ret != TX_SUCCESS) {
    return ret;
  }

  ret = tx_thread_create(&teseoConsumerTaskHandle, "TeseoConsumerTask", TeseoConsumerTask, 0,
                         pointer, CONSUMER_STACK_SIZE, TESEO_CONSUMER_TASK_PRIORITY,
                         teseo_consumer_task_preemption_th,
                         TX_NO_TIME_SLICE, TX_AUTO_START);
  
  return ret;
[#else]
#if (osCMSIS < 0x20000U)
  osThreadDef(teseoConsumerTask, TeseoConsumerTask, osPriorityNormal, 0, CONSUMER_STACK_SIZE);
  teseoConsumerTaskHandle = osThreadCreate(osThread(teseoConsumerTask), NULL);
#else
  task_attributes.name = "teseoConsumerTask";
  task_attributes.stack_size = CONSUMER_STACK_SIZE;
  teseoConsumerTaskHandle = osThreadNew(TeseoConsumerTask, NULL, (const osThreadAttr_t *)&task_attributes);
#endif /* osCMSIS */
[/#if]
}

#if (USE_I2C == 1)
/* This function creates a background task for I2C FSM */
[#if useTHREADX]
static UINT Background_Task_Init(VOID *memory_ptr)
[#else]
static void Background_Task_Init(void)
[/#if]
{
[#if useTHREADX]
  TX_BYTE_POOL *byte_pool = (TX_BYTE_POOL*)memory_ptr;
  UINT ret = TX_SUCCESS;
  CHAR *pointer;
  UINT teseo_background_task_preemption_th = TESEO_BACKGROUND_TASK_PRIORITY;

  ret = tx_byte_allocate(byte_pool, (VOID **)&pointer, BACKGROUND_STACK_SIZE, TX_NO_WAIT);
  if (ret != TX_SUCCESS) {
    return ret;
  }

  ret = tx_thread_create(&backgroundTaskHandle, "BackgroundTask", BackgroundTask, 0,
                         pointer, BACKGROUND_STACK_SIZE, TESEO_BACKGROUND_TASK_PRIORITY, teseo_background_task_preemption_th,
                         TX_NO_TIME_SLICE, TX_AUTO_START);  
  return ret;
[#else]
#if (osCMSIS < 0x20000U)
  osThreadDef(backgroundTask, BackgroundTask, osPriorityNormal, 0, BACKGROUND_STACK_SIZE);
  backgroundTaskHandle = osThreadCreate(osThread(backgroundTask), NULL);
#else
  task_attributes.name = "backgroundTask";
  task_attributes.stack_size = BACKGROUND_STACK_SIZE;
  backgroundTaskHandle = osThreadNew(BackgroundTask, NULL, (const osThreadAttr_t *)&task_attributes);
#endif /* osCMSIS */
[/#if]
}
#endif /* USE_I2C */

/* This function creates the task reading input from the cocsole */
[#if useTHREADX]
static UINT Console_Parse_Task_Init(VOID *memory_ptr)
[#else]
static void Console_Parse_Task_Init(void)
[/#if]
{
[#if useTHREADX]
  TX_BYTE_POOL *byte_pool = (TX_BYTE_POOL*)memory_ptr;
  UINT ret = TX_SUCCESS;
  CHAR *pointer;
  UINT teseo_console_task_preemption_th = TESEO_CONSOLE_TASK_PRIORITY;

  ret = tx_byte_allocate(byte_pool, (VOID **)&pointer, CONSOLE_STACK_SIZE, TX_NO_WAIT);
  if (ret != TX_SUCCESS) {
    return ret;
  }

  ret = tx_thread_create(&consoleParseTaskHandle, "ConsoleParseTask", ConsoleParseTask, 0,
                         pointer, CONSOLE_STACK_SIZE, TESEO_CONSOLE_TASK_PRIORITY, teseo_console_task_preemption_th,
                         TX_NO_TIME_SLICE, TX_AUTO_START);
  
  return ret;
[#else]
#if (osCMSIS < 0x20000U)
  osThreadDef(consoleParseTask, ConsoleParseTask, osPriorityNormal, 0, CONSOLE_STACK_SIZE);
  consoleParseTaskHandle = osThreadCreate(osThread(consoleParseTask), NULL);
#else
  task_attributes.name = "consoleParseTask";
  task_attributes.stack_size = CONSOLE_STACK_SIZE;
  consoleParseTaskHandle = osThreadNew(ConsoleParseTask, NULL, (const osThreadAttr_t *)&task_attributes);
#endif /* osCMSIS */
[/#if]
}

/* TeseoConsumerTask function */
[#if useTHREADX]
static void TeseoConsumerTask(ULONG argument)
[#else]
#if (osCMSIS < 0x20000U)
static void TeseoConsumerTask(void const *argument)
#else
static void TeseoConsumerTask(void *argument)
#endif /* osCMSIS */
[/#if]
{
[#if useCUSTOMBOARD]
  const CUSTOM_GNSS_Msg_t *gnssMsg;

  CUSTOM_GNSS_Init(CUSTOM_TESEO_LIV3F);
  
  for(;;)
  {
    if(btnRst == 1)
    {
      CUSTOM_GNSS_Reset(CUSTOM_TESEO_LIV3F);
      btnRst = 0;
    }

    gnssMsg = CUSTOM_GNSS_GetMessage(CUSTOM_TESEO_LIV3F);
    if(gnssMsg == NULL)
    {
      continue;
    }

    PRINT_OUT((char*)gnssMsg->buf);
    CUSTOM_GNSS_ReleaseMessage(CUSTOM_TESEO_LIV3F, gnssMsg);
  }
[#else]
  const GNSS1A1_GNSS_Msg_t *gnssMsg;

  GNSS1A1_GNSS_Init(GNSS1A1_TESEO_LIV3F);
  
  for(;;)
  {
    if(btnRst == 1)
    {
      GNSS1A1_GNSS_Reset(GNSS1A1_TESEO_LIV3F);
      btnRst = 0;
    }

    gnssMsg = GNSS1A1_GNSS_GetMessage(GNSS1A1_TESEO_LIV3F);
    if(gnssMsg == NULL)
    {
      continue;
    }

    PRINT_OUT((char*)gnssMsg->buf);
    GNSS1A1_GNSS_ReleaseMessage(GNSS1A1_TESEO_LIV3F, gnssMsg);
  }
[/#if]
}

#if (USE_I2C == 1)
/* BackgroundTask function */
[#if useTHREADX]
static void BackgroundTask(ULONG argument)
[#else]
#if (osCMSIS < 0x20000U)
static void BackgroundTask(void const *argument)
#else
static void BackgroundTask(void *argument)
#endif /* osCMSIS */
[/#if]
{
  for(;;)
  {
[#if useCUSTOMBOARD]
    CUSTOM_GNSS_BackgroundProcess(CUSTOM_TESEO_LIV3F);
[#else]
    GNSS1A1_GNSS_BackgroundProcess(GNSS1A1_TESEO_LIV3F);
[/#if]
  }
}
#endif /* USE_I2C */

/* Serial Port Parse Task function */
[#if useTHREADX]
static void ConsoleParseTask(ULONG argument)
[#else]
#if (osCMSIS < 0x20000U)
static void ConsoleParseTask(void const *argument)
#else
static void ConsoleParseTask(void *argument)
#endif /* osCMSIS */
[/#if]
{
  int32_t status;
  uint8_t buffer[128];
  uint16_t rxLen;
[#if useCUSTOMBOARD]
  CUSTOM_GNSS_Msg_t gnssMsg;
[#else]
  GNSS1A1_GNSS_Msg_t gnssMsg;
[/#if]

  for(;;)
  {
    while(!ConsoleReadable())
    {
[#if useTHREADX]
      tx_thread_relinquish();
[#else]
      osThreadYield();
[/#if]
    }
    memset(buffer, 0, sizeof(buffer));
    HAL_UART_Receive(&hcom_uart[COM1], buffer, sizeof(buffer), 100);
    rxLen = strlen((char *)buffer);

    gnssMsg.buf = buffer;
    gnssMsg.len = rxLen;
[#if useCUSTOMBOARD]
    status = CUSTOM_GNSS_Send(CUSTOM_TESEO_LIV3F, &gnssMsg);
[#else]
    status = GNSS1A1_GNSS_Send(GNSS1A1_TESEO_LIV3F, &gnssMsg);
[/#if]

    if (status != BSP_ERROR_NONE)
    {
      PRINT_OUT("Error sending command\n\n");
    }
  }  
}

/**
 * @brief  BSP Push Button callback
 * @param  Button Specifies the pin connected EXTI line
 * @retval None.
 */
void BSP_PB_Callback(Button_TypeDef Button)
{
  btnRst = 1;   
}

static int ConsoleReadable(void)
{
  /*  
   * To avoid a target blocking case, let's check for
   *  possible OVERRUN error and discard it
   */
  if(__HAL_UART_GET_FLAG(&hcom_uart[COM1], UART_FLAG_ORE)) {
    __HAL_UART_CLEAR_OREFLAG(&hcom_uart[COM1]);
  }
  // Check if data is received
  return (__HAL_UART_GET_FLAG(&hcom_uart[COM1], UART_FLAG_RXNE) != RESET) ? 1 : 0;
}
