[#ftl]
[#assign useTHREADX = false]
[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("USE_THREADX_NATIVE_API")]
[#assign useTHREADX = true]
[/#if]

[/#list]
[/#if]
  /* Initialize the BSP common utilities*/
  if(BSP_COM_Init(COM1) != BSP_ERROR_NONE)
  {
    Error_Handler();
  }
