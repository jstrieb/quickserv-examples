/* bloom-create.c
 *
 * Command-line program to create a Bloom filter.
 *
 * Created by Jacob Strieb
 * January 2021
 */


#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "bloom.h"


/*******************************************************************************
 * Main function
 ******************************************************************************/

int main(int argc, char *argv[]) {
  // Open files specified by user inputs
  FILE *infile = stdin;

  // Allocate a new bloom filter
  byte *bloom;
  if ((bloom = new_bloom(27)) == NULL) {
    perror("Unable to create Bloom filter");
    return EXIT_FAILURE;
  }

  // Add strings to the bloom filter from the input, line-by-line
  size_t n = 0;
  char *buffer = NULL;
  ssize_t bytes_read;
  while ((bytes_read = getline(&buffer, &n, infile)) != -1) {
    assert(bytes_read >= 1);
    // Use one less byte of the buffer since it includes the deliminter due to
    // the implementation of getline, and hashing the newline will cause
    // problems with JavaScript strings later on
    // NOTE: Important to see that bytes_read is VERY different from n, which
    // is the allocated size -- originally, missing this led to a gnarly bug
    add_bloom(bloom, 27, (uint8_t *)buffer, bytes_read - 1);
  }

  // Write the Bloom filter to stdout
  FILE *outfile = stdout;
  fwrite((void *)bloom, sizeof(uint8_t), 1 << 24, outfile);

  // Clean up
  free(buffer);
  free_bloom(bloom);

  return EXIT_SUCCESS;

  (void)argc;
  (void)argv;
}
