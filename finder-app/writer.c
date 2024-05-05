#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <string.h>

int main(int argc, char *argv[]) {
    openlog("writer", LOG_PID | LOG_CONS, LOG_USER); // Open syslog with the identity "writer"

    // Check if arguments are provided correctly
    if (argc < 3) {
        syslog(LOG_ERR, "Invalid number of arguments");
        closelog();
        return 1;
    }

    char *writefile = argv[1];
    char *writestr = argv[2];

    FILE *file = fopen(writefile, "w");
    if (file == NULL) {
        syslog(LOG_ERR, "Error opening file %s", writefile);
        closelog();
        return 1;
    }

    // Write string to file
    if (fprintf(file, "%s\n", writestr) < 0) {
        syslog(LOG_ERR, "Error writing to file %s", writefile);
        fclose(file);
        closelog();
        return 1;
    }

    fclose(file);

    // Log success message
    syslog(LOG_DEBUG, "Writing \"%s\" to %s", writestr, writefile);

    closelog();
    return 0;
}
