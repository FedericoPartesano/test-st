[#ftl]
/**
  ******************************************************************************
  * @file    ${name}
  * @author  SRA Application Team
  * @brief   Defines configuration parameters for GNSS advanced features.
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+ "/license.tmp"/][#--include License text --]
  ******************************************************************************
  */#n

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef GNSS_FEATURE_CFG_DATA_H
#define GNSS_FEATURE_CFG_DATA_H

#ifdef __cplusplus
 extern "C" {
#endif 

/* Includes ------------------------------------------------------------------*/
#include "gnss_geofence.h"
#include "gnss_datalog.h"

/** @addtogroup PROJECTS
 * @{
 */
 
/** @addtogroup APPLICATIONS
 * @{
 */

/** @addtogroup SimOSGetPos
 * @{
 */
 	
/** @addtogroup SimOSGetPos_GNSS_FEATURE_CFG_DATA GNSS_FEATURE_CFG_DATA
 * @{
 */

/* See CDB-ID 228 - HIGH_BITS Mask */
#define ODOMETER_NMEA_MSG 50U
#define GEOFENCE_NMEA_MSG 51U
#define DATALOG_NMEA_MSG 52U

#define ODOMETER ((uint32_t)1<<(ODOMETER_NMEA_MSG-32U))
#define GEOFENCE ((uint32_t)1<<(GEOFENCE_NMEA_MSG-32U))
#define DATALOG ((uint32_t)1<<(DATALOG_NMEA_MSG-32U))

GNSSGeofence_t Geofence_STLecce = {
    .id = 5,
    .enabled = 1,
    .tolerance = 1,
    .lat = 40.336055,
    .lon = 18.120611,
    .radius = 200,
    .status = 0
  };
  
GNSSGeofence_t Geofence_Catania = {
    .id = 6,
    .enabled = 1,
    .tolerance = 1,
    .lat = 37.4908266,
    .lon = 15.0073063,
    .radius = 200,
    .status = 0
};

GNSSDatalog_t SampleDatalog = {
  .enableBufferFullAlarm = 0,
  .enableCircularBuffer = 1,
  .minRate = 5,
  .minSpeed = 0,
  .minPosition = 0,
  .logMask = 1
};
/**
 * @}
 */

/**
 * @}
 */

/**
 * @}
 */
 
/**
 * @}
 */

#ifdef __cplusplus
}
#endif

#endif /* GNSS_FEATURE_CFG_DATA_H */

