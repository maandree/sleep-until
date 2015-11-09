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
#include <alloca.h>
#include <string.h>
#include <stdlib.h>



int main(int argc, char* argv[])
{
  char* argv0;
  char float_part[10];
  struct itimerspec* values;
  int i;
  
  if (argc < 2)
    return 0;
  
  argv0 = argv[0];
  argc--, argv--;
  
  values = alloca(argc * sizeof(*values));
  memset(values, 0, argc * sizeof(*values));
  float_part[9] = '\0';
  for (i = 0; i < argc; i++)
    {
      char* p1 = argv[i];
      char* p2 = strchr(p1, '.');
      char excess;
      size_t len;
      if (p2)
	*p2++ = '\0';
      
      values[i].it_value.tv_sec = (time_t)atoll(p1);
      
      if (p2)
	{
	  len = strlen(p2);
	  memset(float_part, '0', 9 * sizeof(char));
	  excess = len > 9 ? p2[9] : '0';
	  len = len > 9 ? 9 : len;
	  memcpy(float_part + 9 - len, p2, len * sizeof(char));
	  values[i].it_value.tv_nsec = atol(float_part);
	  if ((excess >= '5') && (values[i].it_value.tv_nsec++ == 999999999L))
	    values[i].it_value.tv_nsec = 0, values[i].it_value.tv_sec++;
	}
    }
  
  return 0;
}

