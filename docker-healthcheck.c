#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

int main(void) {
  const char *host = "127.0.0.1";
  const char *port = getenv("PORT");
  if (port == NULL || port[0] == '\0') {
    port = "4000";
  }

  struct addrinfo hints;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;

  struct addrinfo *result = NULL;
  int gai = getaddrinfo(host, port, &hints, &result);
  if (gai != 0) {
    fprintf(stderr, "healthcheck getaddrinfo failed: %s\n", gai_strerror(gai));
    return 1;
  }

  int fd = -1;
  for (struct addrinfo *rp = result; rp != NULL; rp = rp->ai_next) {
    fd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (fd == -1) {
      continue;
    }
    if (connect(fd, rp->ai_addr, rp->ai_addrlen) == 0) {
      break;
    }
    close(fd);
    fd = -1;
  }
  freeaddrinfo(result);

  if (fd == -1) {
    perror("healthcheck connect failed");
    return 1;
  }

  const char request[] =
      "GET /api/v1/health HTTP/1.1\r\n"
      "Host: 127.0.0.1\r\n"
      "Connection: close\r\n"
      "\r\n";

  ssize_t written = write(fd, request, sizeof(request) - 1);
  if (written < 0) {
    perror("healthcheck write failed");
    close(fd);
    return 1;
  }

  char response[64];
  ssize_t read_count = read(fd, response, sizeof(response) - 1);
  close(fd);
  if (read_count <= 0) {
    perror("healthcheck read failed");
    return 1;
  }
  response[read_count] = '\0';

  if (strncmp(response, "HTTP/1.1 200", 12) == 0 ||
      strncmp(response, "HTTP/1.0 200", 12) == 0) {
    return 0;
  }

  fprintf(stderr, "healthcheck unexpected response: %.32s\n", response);
  return 1;
}
