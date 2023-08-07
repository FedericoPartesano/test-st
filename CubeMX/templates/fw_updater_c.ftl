[#ftl]
  if (HAL_UART_Receive(&hcom_uart[COM1], &fromPC[idxPC], 1, 0) == HAL_OK)
  {
    HAL_UART_Transmit(&hgnss_uart, &fromPC[idxPC], 1, 0);
    idxPC++;
    idxPC %= BUFFER_SIZE;
  }

  if (HAL_UART_Receive(&hgnss_uart, &fromGNSS[idxGNSS], 1, 0) == HAL_OK)
  {
    HAL_UART_Transmit(&hcom_uart[COM1], &fromGNSS[idxGNSS], 1, 0);
    idxGNSS++;
    idxGNSS %= BUFFER_SIZE;
  }


