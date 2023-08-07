[#ftl]
[#assign useCUSTOMBOARD = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("BSP_GNSS")]
[#assign useCUSTOMBOARD = true]
[/#if]

[/#list]
[/#if]

/* TeseoConsumerTask function */
static void MX_SimOSGetPos_Process(void)
{
  GNSSParser_Status_t status, check;
[#if useCUSTOMBOARD]
  const CUSTOM_GNSS_Msg_t *gnssMsg;
[#else]
  const GNSS1A1_GNSS_Msg_t *gnssMsg;
[/#if]
#if (configUSE_FEATURE == 1)
  static int config_done = 0;
#endif  

[#if useCUSTOMBOARD]
  CUSTOM_GNSS_Init(CUSTOM_TESEO_LIV3F);
[#else]
  GNSS1A1_GNSS_Init(GNSS1A1_TESEO_LIV3F);
[/#if]
  
  GNSS_PARSER_Init(&GNSSParser_Data);

  for(;;)
  {
#if (USE_I2C == 1)
[#if useCUSTOMBOARD]
    CUSTOM_GNSS_BackgroundProcess(CUSTOM_TESEO_LIV3F);
[#else]
    GNSS1A1_GNSS_BackgroundProcess(GNSS1A1_TESEO_LIV3F);
[/#if]
#endif /* USE_I2C */

#if (configUSE_FEATURE == 1)
    /* See CDB-ID 201 - This LOW_BITS Mask enables the following messages:
     * 0x1 $GPGNS Message
     * 0x2 $GPGGA Message
     * 0x4 $GPGSA Message
     * 0x8 $GPGST Message
     * 0x40 $GPRMC Message
     * 0x80000 $GPGSV Message
     * 0x100000 $GPGLL Message
     */
    if(!config_done)
    {
      int lowMask = 0x18004F;
      int highMask = GEOFENCE;
      PRINT_OUT("\n\rConfigure Message List\n\r");
      AppCfgMsgList(lowMask, highMask);
      HAL_Delay(1000);  //Allows to catch the reply from Teseo

      PRINT_OUT("\n\rEnable Geofence\r");
      AppEnFeature("GEOFENCE,1");
      HAL_Delay(500);  //Allows to catch the reply from Teseo

      PRINT_OUT("\n\rConfigure Geofence Circle\n\r");
      AppGeofenceCfg("Geofence-Lecce");

      config_done = 1;
    }
#endif /* configUSE_FEATURE */

[#if useCUSTOMBOARD]
    gnssMsg = CUSTOM_GNSS_GetMessage(CUSTOM_TESEO_LIV3F);
[#else]
    gnssMsg = GNSS1A1_GNSS_GetMessage(GNSS1A1_TESEO_LIV3F);
[/#if]
    
    if(gnssMsg == NULL)
    {
      continue;
    }
    
    check = GNSS_PARSER_CheckSanity((uint8_t *)gnssMsg->buf, gnssMsg->len);	

    if(check != GNSS_PARSER_ERROR)
    {
      for(int m = 0; m < NMEA_MSGS_NUM; m++)
      {
        status = GNSS_PARSER_ParseMsg(&GNSSParser_Data, (eNMEAMsg)m, (uint8_t *)gnssMsg->buf);

        if((status != GNSS_PARSER_ERROR) && ((eNMEAMsg)m == GPGGA))
        {
          GNSS_DATA_GetValidInfo(&GNSSParser_Data);
        }
#if (configUSE_FEATURE == 1)
        if((status != GNSS_PARSER_ERROR) && ((eNMEAMsg)m == PSTMGEOFENCE))
        {
          GNSS_DATA_GetGeofenceInfo(&GNSSParser_Data);
        }
        if((status != GNSS_PARSER_ERROR) && ((eNMEAMsg)m == PSTMSGL))
        {
          GNSS_DATA_GetMsglistAck(&GNSSParser_Data);
        }
        if((status != GNSS_PARSER_ERROR) && ((eNMEAMsg)m == PSTMSAVEPAR))
        {
          GNSS_DATA_GetGNSSAck(&GNSSParser_Data);
        }
#endif /* configUSE_FEATURE */
      }
    }

[#if useCUSTOMBOARD]
    CUSTOM_GNSS_ReleaseMessage(CUSTOM_TESEO_LIV3F, gnssMsg);
[#else]
    GNSS1A1_GNSS_ReleaseMessage(GNSS1A1_TESEO_LIV3F, gnssMsg);
[/#if]
  }
}


#if (configUSE_FEATURE == 1)
/* CfgMessageList */
static void AppCfgMsgList(int lowMask, int highMask)
{
  GNSS_DATA_CfgMessageList(lowMask, highMask);
}

static void AppEnFeature(char *command)
{
  if(strcmp(command, "GEOFENCE,1") == 0)
  {
    GNSS_DATA_EnableGeofence(1);
  }
  if(strcmp(command, "GEOFENCE,0") == 0)
  {
    GNSS_DATA_EnableGeofence(0);
  }
}

static void AppGeofenceCfg(char *command)
{ 
  if(strcmp(command, "Geofence-Lecce") == 0)
  {
    GNSS_DATA_ConfigGeofence(&Geofence_STLecce);
  }
  if(strcmp(command, "Geofence-Catania") == 0)
  {
    GNSS_DATA_ConfigGeofence(&Geofence_Catania);
  }
}
#endif /* configUSE_FEATURE */
