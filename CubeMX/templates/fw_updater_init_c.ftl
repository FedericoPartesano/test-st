[#ftl]
[#assign useCUSTOMBOARD = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("BSP_GNSS")]
[#assign useCUSTOMBOARD = true]
[/#if]

[/#list]
[/#if]

  idxPC = 0;
  idxGNSS = 0;

  if(BSP_COM_Init(COM1) != BSP_ERROR_NONE)
  {
    Error_Handler();
  }
[#if useCUSTOMBOARD]
  CUSTOM_GNSS_Init(CUSTOM_TESEO_LIV3F);
[#else]
  GNSS1A1_GNSS_Init(GNSS1A1_TESEO_LIV3F);
[/#if]
