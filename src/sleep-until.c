/**
 * sleep-until – Sleeps until a specified time
 * 
 * Copyright © 2015  Mattias Andrée (maandree@member.fsf.org)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <sys/timerfd.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>


int main(int argc, char* argv[])
{
  char* argv0;
  char float_part[10];
  struct itimerspec value;
  struct itimerspec largest_value;
  int i, fd = -1, clocks = 0;
  uint64_t _expirations;
  int clockid = CLOCK_REALTIME;
  
  if (argc < 2)
    return 0;
  
  argv0 = argv[0];
  argc--, argv++;
  
  memset(&value, 0, sizeof(value));
  float_part[9] = '\0';
  for (i = 0; i < argc; i++)
    {
      char* p1 = argv[i];
      char* p2;
      char excess;
      size_t len;
      
      if (strstr(p1, "CLOCK_") != p1)
	goto parse_time;
$>cat /usr/include/bits/time.h | grep '^ *# *define  *CLOCK_' | grep -Po 'CLOCK_[^[:blank:]]*' |
$>while read c; do
      else if (!strcmp(p1, "${c}"))
	clockid = ${c};
$>done
      else
	clockid = -1;
	clocks++;
      continue;
      
    parse_time:
      if ((p2 = strchr(p1, '.')))
	*p2++ = '\0';
      
      value.it_value.tv_sec = (time_t)atoll(p1);
      
      if (p2)
	{
	  len = strlen(p2);
	  memset(float_part, '0', 9 * sizeof(char));
	  excess = len > 9 ? p2[9] : '0';
	  len = len > 9 ? 9 : len;
	  memcpy(float_part + 9 - len, p2, len * sizeof(char));
	  value.it_value.tv_nsec = atol(float_part);
	  if ((excess >= '5') && (value.it_value.tv_nsec++ == 999999999L))
	    value.it_value.tv_nsec = 0, value.it_value.tv_sec++;
	}
      
      if (i == 0)
	largest_value = value;
      else if (value.it_value.tv_sec > largest_value.it_value.tv_sec)
	largest_value = value;
      else if (value.it_value.tv_sec == largest_value.it_value.tv_sec)
	if (value.it_value.tv_nsec > largest_value.it_value.tv_nsec)
	  largest_value = value;
    }
  
  if (clocks == argc)
    return 0;
  
  fd = timerfd_create(clockid, 0);
  if (fd < 0)
    goto fail;
  if (timerfd_settime(fd, TFD_TIMER_ABSTIME, &largest_value, NULL))
    goto fail;
  
  for (;;)
    {
      if (clock_gettime(clockid, &(value.it_value)))
	goto fail;
      if (value.it_value.tv_sec > largest_value.it_value.tv_sec)
        break;
      if (value.it_value.tv_sec == largest_value.it_value.tv_sec)
	if (value.it_value.tv_nsec >= largest_value.it_value.tv_nsec)
	  break;
      if (read(fd, &_expirations, (size_t)8) < 8)
	{
	  if (errno == EINTR)
	    continue;
	  goto fail;
	}
    }
  
  close(fd);
  return 0;
 fail:
  perror(argv0);
  if (fd >= 0)  close(fd);
  return 1;
}

