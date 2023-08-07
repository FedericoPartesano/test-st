[#ftl]
  if(BSP_COM_Init(COM1) != BSP_ERROR_NONE)
  {
    Error_Handler();
  }

  PRINT_DBG("Booting...\r\n");