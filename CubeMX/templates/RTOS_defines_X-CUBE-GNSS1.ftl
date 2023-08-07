[#ftl]
[#assign useGETPOS = false]
[#assign useVIRTUALCOMPORT = false]

[#if RTEdatas??]
[#list RTEdatas as define]

[#if define?contains("GETPOS_APP")]
[#assign useGETPOS = true]
[/#if]

[#if define?contains("VCOM_APP")]
[#assign useVIRTUALCOMPORT = true]
[/#if]

[/#list]
[/#if]

[#if useGETPOS | useVIRTUALCOMPORT]
/* Minimum stack size per thread  */
#define GNSS_THREAD_MINIMUM_STACK                (1024)

#define GNSS_NUM_OF_THREADS                      (4)
#define GNSS_APP_MEM_POOL_SIZE                   (GNSS_NUM_OF_THREADS * GNSS_THREAD_MINIMUM_STACK)
[#else]
#define GNSS_APP_MEM_POOL_SIZE                   (1024)
[/#if]
