#include "systemcalls.h"

/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{

/*
 * TODO  add your code here
 *  Call the system() function with the command set in the cmd
 *   and return a boolean true if the system() call completed with success
 *   or false() if it returned a failure
*/

	int retval = system( cmd );
	
	if ( retval == -1 ) {
		return false;
	} 

    return true;
}

/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];

/*
 * TODO:
 *   Execute a system command by calling fork, execv(),
 *   and wait instead of system (see LSP page 161).
 *   Use the command[0] as the full path to the command to execute
 *   (first argument to execv), and use the remaining arguments
 *   as second argument to the execv() command.
 *
*/	
    
    va_end(args);
    pid_t pid = fork();

    if ( pid == -1 ) {
        perror("fork");
        exit(EXIT_FAILURE);
    } else if ( pid == 0 ) { // Child process
        // Execute the command using execv
        if (execv(command[0], command) == -1) {
            perror("execv");
            exit(EXIT_FAILURE);
        }
    } else {
		// Wait for the child process to terminate
		int status;
		 
		waitpid(pid, &status, 0);
	 
		if ( WIFEXITED(status) )
		{    
		    if ( WEXITSTATUS(status) != 0 ) {
		    	printf("Exit status of the child was %d\n", WEXITSTATUS(status));
		    	return false;
			}  
		}
    }
    

    return true;
}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];


/*
 * TODO
 *   Call execv, but first using https://stackoverflow.com/a/13784315/1446624 as a refernce,
 *   redirect standard out to a file specified by outputfile.
 *   The rest of the behaviour is same as do_exec()
 *
*/

	printf("command %s \n", command[0]);
	pid_t pid = fork();

    if (pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    } else if ( pid == 0 ) { // Child process
        // Open the output file for writing, create if it does not exist, truncate if it does
        int fd = open(outputfile, O_RDWR | O_CREAT);
        if (fd == -1) {
            perror("open");
        	exit(EXIT_FAILURE);
        }

        // Redirect stdout to the output file
        if ( dup2(fd, STDOUT_FILENO) == -1) {
            perror("dup2");
            close(fd);
            exit(EXIT_FAILURE);
        }

        // Close the original file descriptor for the output file
        close(fd);

        // Execute the command using execv
        if (execv(command[0], command) == -1) {
            perror("execv");
            exit(EXIT_FAILURE);
        }
    } else {
		// Wait for the child process to terminate
		int status;
		 
		waitpid(pid, &status, 0);
	 
		if ( WIFEXITED(status) )
		{    
		    if ( WEXITSTATUS(status) != 0 ) {
		    	printf("Exit status of the child was %d\n", WEXITSTATUS(status));
		    	return false;
			}  
		}
    }

/*
	pid_t kidpid;
	int fd = open( outputfile, O_RDWR|O_TRUNC|O_CREAT );
	if (fd < 0) { perror("open"); abort(); }
	switch ( kidpid = fork() ) {
	  case -1: perror("fork"); abort();
	  case 0:
	  	printf("No errors opening file \n");
		close(fd);
		execvp(command[0], command); perror("execvp"); abort();
	  default:
		close(fd);
	}*/

    va_end(args);

    return true;
}
