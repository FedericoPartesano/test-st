[#ftl]
  if (tx_byte_pool_create(&gnss_app_byte_pool, "GNSS App memory pool", gnss_byte_pool_buffer, GNSS_APP_MEM_POOL_SIZE) != TX_SUCCESS)
  {
    /* USER CODE BEGIN GNSS_Byte_Pool_Error */

    /* USER CODE END GNSS_Byte_Pool_Error */
  }
  else
  {
    /* USER CODE BEGIN GNSS_Byte_Pool_Success */

    /* USER CODE END GNSS_Byte_Pool_Success */

    memory_ptr = (VOID *)&gnss_app_byte_pool;
