/**
  ******************************************************************************
  * @file    net_tcp_wifi.c
  * @author  MCD Application Team
  * @brief   Network abstraction at transport layer level. TCP implementation
  *          on ST WiFi connectivity API.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2021 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* Includes ------------------------------------------------------------------*/
#include "net_internal.h"

#ifdef USE_WIFI

/* Private defines -----------------------------------------------------------*/
/* The socket timeout of the non-blocking sockets is supposed to be 0.
 * But the underlying component does not necessarily supports a non-blocking
 * socket interface.
 * The NOBLOCKING timeouts are intended to be set to the lowest possible value
 * supported by the underlying component. */
#define NET_DEFAULT_NOBLOCKING_WRITE_TIMEOUT  1
#define NET_DEFAULT_NOBLOCKING_READ_TIMEOUT   1

/* Workaround for the incomplete WIFI_LL API */
#ifdef ES_WIFI_MAX_SSID_NAME_SIZE
#define WIFI_PAYLOAD_SIZE                           ES_WIFI_PAYLOAD_SIZE
#endif

/* Private typedef -----------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
int net_sock_create_wifi(net_hnd_t nethnd, net_sockhnd_t * sockhnd, net_proto_t proto);
int net_sock_open_wifi(net_sockhnd_t sockhnd, const char * hostname, int remoteport, int localport);
int net_sock_recv_tcp_wifi(net_sockhnd_t sockhnd, uint8_t * buf, size_t len);
int net_sock_recvfrom_udp_wifi(net_sockhnd_t sockhnd, uint8_t * const buf, size_t len, net_ipaddr_t * remoteaddress, int * remoteport);
int net_sock_send_tcp_wifi(net_sockhnd_t sockhnd, const uint8_t * buf, size_t len);
int net_sock_sendto_udp_wifi(net_sockhnd_t sockhnd, const uint8_t * buf, size_t len,  net_ipaddr_t * remoteaddress, int remoteport);
int net_sock_close_tcp_wifi(net_sockhnd_t sockhnd);
int net_sock_destroy_tcp_wifi(net_sockhnd_t sockhnd);

/* Functions Definition ------------------------------------------------------*/

int net_sock_create_wifi(net_hnd_t nethnd, net_sockhnd_t * sockhnd, net_proto_t proto)
{
  int rc = NET_ERR;
  net_ctxt_t *ctxt = (net_ctxt_t *) nethnd;
  net_sock_ctxt_t *sock = NULL;
  
  sock = net_malloc(sizeof(net_sock_ctxt_t));
  if (sock == NULL)
  {
    msg_error("net_sock_create allocation failed.\n");
    rc = NET_ERR;
  }
  else
  {
    memset(sock, 0, sizeof(net_sock_ctxt_t));
    sock->net = ctxt;
    sock->next = ctxt->sock_list;
    sock->methods.open      = (net_sock_open_wifi);
    switch(proto)
    {
      case NET_PROTO_TCP:
        sock->methods.recv      = (net_sock_recv_tcp_wifi);
        sock->methods.send      = (net_sock_send_tcp_wifi);
        break;
      case NET_PROTO_UDP:
        sock->methods.recvfrom  = (net_sock_recvfrom_udp_wifi);
        sock->methods.sendto    = (net_sock_sendto_udp_wifi);
        break;
      default:
        free(sock);
        return NET_PARAM;
    }
    sock->methods.close     = (net_sock_close_tcp_wifi);
    sock->methods.destroy   = (net_sock_destroy_tcp_wifi);
    sock->proto             = proto;
    sock->blocking          = NET_DEFAULT_BLOCKING;
    sock->read_timeout      = NET_DEFAULT_BLOCKING_READ_TIMEOUT;
    sock->write_timeout     = NET_DEFAULT_BLOCKING_WRITE_TIMEOUT;
    ctxt->sock_list         = sock; /* Insert at the head of the list */
    *sockhnd = (net_sockhnd_t) sock;

    rc = NET_OK;
  }
  
  return rc;
}


int net_sock_open_wifi(net_sockhnd_t sockhnd, const char * hostname, int remoteport, int localport)
{
  int rc = NET_ERR;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  uint8_t ip_addr[4] = { 0, 0, 0, 0 };
  WIFI_Protocol_t proto;
  
  sock->underlying_sock_ctxt = (net_sockhnd_t) -1; /* Initialize to a non-null value which may not be confused with a valid port number. */
  
  /* Find a free underlying socket on the network interface. */
  bool underlying_socket_busy[WIFI_MAX_CONNECTIONS];
  memset(underlying_socket_busy, 0, sizeof(underlying_socket_busy));
  
  net_sock_ctxt_t * cur = sock->net->sock_list;
  do 
  {
    if ( ((cur->proto == NET_PROTO_TCP) || (cur->proto == NET_PROTO_UDP) )&& ((int) cur->underlying_sock_ctxt >= 0) )
    {
      underlying_socket_busy[(int) cur->underlying_sock_ctxt] = true;
    }
    cur = cur->next;
  } while (cur != NULL);
  
  for (int i = 0; i < WIFI_MAX_CONNECTIONS; i++)
  {
    if (underlying_socket_busy[i] == false)
    {
      sock->underlying_sock_ctxt = (net_sockhnd_t) i;
      break;
    }
  }
  
  /* Free socket found */
  if (sock->underlying_sock_ctxt >= 0)
  {
    switch(sock->proto)
    {
      case NET_PROTO_TCP:
        if (localport != 0)
        { /* TCP local port setting is not implemented */
          rc = NET_PARAM;
        }
        else
        {
          if (WIFI_GetHostAddress((char *)hostname, ip_addr) != WIFI_STATUS_OK)
          {
            // TODO: Defect report on WIFI_GetHostAddress() which return code is not informative.
            // NB: This blocking call may take several seconds before returning. An asynchronous interface should be added.
            msg_info("The address of %s could not be resolved.\n", hostname);
          }
          else
          {
            proto = WIFI_TCP_PROTOCOL;
            rc = NET_OK;
          }
        }
        break;
      case NET_PROTO_UDP:
        /* Record the local port binding. */
        sock->localport = localport;
        proto = WIFI_UDP_PROTOCOL;
        rc = NET_OK;
        break;
      default:
        ;
    }
        
    /* The Wifi "client connection" must be opened even in UDP mode. Otherwise the incoming traffic may be lost. */  
    if (rc == NET_OK)
    {
      if( WIFI_STATUS_OK != WIFI_OpenClientConnection((uint32_t) sock->underlying_sock_ctxt,
            proto, "", ip_addr, remoteport, localport) )
      {
        msg_error("Failed opening the underlying Wifi socket %d.\n", (int) sock->underlying_sock_ctxt);
        sock->underlying_sock_ctxt = (net_sockhnd_t) -1;
        rc = NET_ERR;
      }
    }
  }
  else
  {
    msg_error("Could not find a free socket on the specified network interface.\n");
    rc = NET_PARAM;
  }
  
  return rc;
}


int net_sock_recv_tcp_wifi(net_sockhnd_t sockhnd, uint8_t * buf, size_t len)
{
  int rc = 0;
  WIFI_Status_t status = WIFI_STATUS_OK;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  uint16_t read = 0;
  uint16_t tmp_len = MIN(len, WIFI_PAYLOAD_SIZE);
  uint8_t * tmp_buf = buf;
  uint32_t start_time = HAL_GetTick();
    
  /* Read the received payload by chunks of WIFI_PAYLOAD_SIZE bytes because of
   * a constraint of WIFI_ReceiveData(). */
  do
  {
    if ( (sock->blocking == true) && (net_timeout_left_ms(start_time, HAL_GetTick(), sock->read_timeout) <= 0) )
    {
      rc = NET_TIMEOUT;
      break;
    }
    
    status = WIFI_ReceiveData((uint8_t) ((uint32_t)sock->underlying_sock_ctxt & 0xFF), tmp_buf, tmp_len, &read,
                             (sock->blocking == true) ? sock->read_timeout : NET_DEFAULT_NOBLOCKING_READ_TIMEOUT);
    msg_debug("Read %d/%d.\n", read, tmp_len);
    if (status != WIFI_STATUS_OK)
    {
      msg_error("net_sock_recv(): error %d in WIFI_ReceiveData() - socket=%d requestedLen=%d received=%d\n",
             status, (int) sock->underlying_sock_ctxt, tmp_len, read);
      msg_error("The port is likely to have been closed by the server.\n")
      rc = NET_EOF;
      break;  
    }
    else
    {
      if (read > tmp_len)
      {
        msg_error("WIFI_ReceiveData() returned a longer payload than requested (%d/%d).\n", read, tmp_len);
        rc = NET_ERR;
        break;
      }
      tmp_buf += read;
      tmp_len = MAX(0, MIN(len - (tmp_buf - buf), WIFI_PAYLOAD_SIZE));
    }
    
  } while ( (read == 0) && (sock->blocking == true) && (rc == 0) );
    
  return (rc < 0) ? rc : tmp_buf - buf;
}


int net_sock_recvfrom_udp_wifi(net_sockhnd_t sockhnd, uint8_t * const buf, size_t len, net_ipaddr_t * remoteaddress, int * remoteport)
{
  int rc = 0;
  WIFI_Status_t status = WIFI_STATUS_OK;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  uint16_t read = 0;
  uint16_t tmp_len = MIN(len, WIFI_PAYLOAD_SIZE);
  uint8_t * tmp_buf = buf;
  uint32_t start_time = HAL_GetTick();

  /* Note: The remote address and the remote port are unknown until a packet is received. */
  { /* Read the received payload by chunks of WIFI_PAYLOAD_SIZE bytes because of
     * a constraint of WIFI_ReceiveData(). */
    do
    {
      uint16_t port = 0;
      uint8_t ip[4] = { 0, 0, 0, 0 };
      if ( (sock->blocking == true) && (net_timeout_left_ms(start_time, HAL_GetTick(), sock->read_timeout) <= 0) )
      {
        rc = NET_TIMEOUT;
        break;
      }
      
      status = WIFI_ReceiveDataFrom((uint8_t) ((uint32_t)sock->underlying_sock_ctxt & 0xFF), tmp_buf, tmp_len, &read,
                               (sock->blocking == true) ? sock->read_timeout : NET_DEFAULT_NOBLOCKING_READ_TIMEOUT, ip , &port);
      msg_debug("Read %d/%d.\n", read, tmp_len);
      if (status != WIFI_STATUS_OK)
      {
        msg_error("net_sock_recv(): error %d in WIFI_ReceiveData() - socket=%d requestedLen=%d received=%d\n",
               status, (int) sock->underlying_sock_ctxt, tmp_len, read);
        msg_error("The port is likely to have been closed by the server.\n")
        rc = NET_EOF;
        break;  
      }
      else
      {
        if (read > tmp_len)
        {
          msg_error("WIFI_ReceiveData() returned a longer payload than requested (%d/%d).\n", read, tmp_len);
          rc = NET_ERR;
          break;
        }
        tmp_buf += read;
        tmp_len = MAX(0, MIN(len - (tmp_buf - buf), WIFI_PAYLOAD_SIZE));
      }
      
      remoteaddress->ipv = NET_IP_V4;
      memset(remoteaddress->ip, 0xFF, sizeof(remoteaddress->ip));
      memcpy(&remoteaddress->ip[12], ip, 4);
      *remoteport = port;
    } while ( (read == 0) && (sock->blocking == true) && (rc == 0) );
  }
  
  return (rc < 0) ? rc : tmp_buf - buf;
}


int net_sock_send_tcp_wifi( net_sockhnd_t sockhnd, const uint8_t * buf, size_t len)
{
  int rc = 0;
  WIFI_Status_t status = WIFI_STATUS_OK;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  uint16_t sent = 0;
  uint32_t start_time = HAL_GetTick();
  
  do
  {
    if ( (sock->blocking == true) && (net_timeout_left_ms(start_time, HAL_GetTick(), sock->write_timeout) <= 0) )
    {
      rc = NET_TIMEOUT;
      break;
    }
    
    status = WIFI_SendData((uint8_t) ((uint32_t)sock->underlying_sock_ctxt & 0xFF), (uint8_t *)buf, len, &sent,
                          (sock->blocking == true) ? sock->write_timeout : NET_DEFAULT_NOBLOCKING_WRITE_TIMEOUT );
    if (status !=  WIFI_STATUS_OK)
    {
      rc = NET_ERR;
      msg_error("Send failed.\n");
      break;
    }
    msg_debug("send %d/%d.\n", sent, len);
  } while ( (sent == 0) && (sock->blocking == true) && (rc == 0) );
  
  return (rc < 0) ? rc : sent;
}


int net_sock_sendto_udp_wifi(net_sockhnd_t sockhnd, const uint8_t * buf, size_t len, net_ipaddr_t * remoteaddress, int remoteport)
{
  int rc = 0;
  WIFI_Status_t status = WIFI_STATUS_OK;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  uint16_t sent = 0;
  uint32_t start_time = HAL_GetTick();
  uint8_t ip_addr[4] = { 0, 0, 0, 0 };
  int16_t port = remoteport;
  
  if (remoteaddress->ipv != NET_IP_V4)
  {
    return NET_PARAM;
  }
  for (int i = 0; i < 4; i++)
  {
    ip_addr[i] = remoteaddress->ip[12+i];
  }
  
  do
  {
    if ( (sock->blocking == true) && (net_timeout_left_ms(start_time, HAL_GetTick(), sock->write_timeout) <= 0) )
    {
      rc = NET_TIMEOUT;
      break;
    }
    
    status = WIFI_SendDataTo((uint8_t) ((uint32_t)sock->underlying_sock_ctxt & 0xFF), (uint8_t *)buf, len, &sent,
                          (sock->blocking == true) ? sock->write_timeout : NET_DEFAULT_NOBLOCKING_WRITE_TIMEOUT, ip_addr, port );
    if (status !=  WIFI_STATUS_OK)
    {
      rc = NET_ERR;
      msg_error("Send failed.\n");
      break;
    }
  
  } while ( (sent == 0) && (sock->blocking == true) && (rc == 0) );
    
  return (rc < 0) ? rc : sent;
}


int net_sock_close_tcp_wifi(net_sockhnd_t sockhnd)
{
  int rc = NET_ERR;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  WIFI_Status_t status = WIFI_CloseClientConnection((uint8_t) ((uint32_t)sock->underlying_sock_ctxt && 0xFF));
  if (status == WIFI_STATUS_OK)
  {
    sock->underlying_sock_ctxt = (net_sockhnd_t) -1;
    rc = NET_OK;
  }
  return rc;
}


int net_sock_destroy_tcp_wifi(net_sockhnd_t sockhnd)
{
  int rc = NET_ERR;
  net_sock_ctxt_t *sock = (net_sock_ctxt_t * ) sockhnd;
  net_ctxt_t *ctxt = sock->net;
    
  /* Find the parent in the linked list.
   * Unlink and free. 
   */
  if (sock == ctxt->sock_list)
  {
    ctxt->sock_list = sock->next;
    rc = NET_OK;
  }
  else
  {
    net_sock_ctxt_t *cur = ctxt->sock_list;
    do
    {
      if (cur->next == sock)
      {
        cur->next = sock->next;
        rc = NET_OK;
        break;
      }
      cur = cur->next;
    } while(cur->next != NULL);
  }
  if (rc == NET_OK)
  {
    net_free(sock);
  }
  
  return rc;
}

#endif /* USE_WIFI */

