#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    
    struct thread_data *data = (struct thread_data *)thread_param;
    
    // Wait for wait_to_obtain_ms milliseconds
    usleep( data->wait_to_obtain_ms * 1000 );
    
    // Obtain the mutex
    // Obtain the mutex
    if ( pthread_mutex_lock( data->mutex ) != 0 ) {
        // Mutex locking failed
        data->thread_complete_success = false;
        return NULL;
    }
    
    // Wait for wait_to_release_ms milliseconds
    usleep( data->wait_to_release_ms * 1000 );

    // Release the mutex
    if ( pthread_mutex_unlock( data->mutex ) != 0 ) {
        // Mutex unlocking failed
        data->thread_complete_success = false;
        return NULL;
    }

    // Set thread_complete_success to true
    data->thread_complete_success = true;
    
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
     
	struct thread_data * thr_data = ( struct thread_data * ) malloc( sizeof( struct thread_data ) );
	
	if ( thr_data == NULL ) {
		return false;
	}
	
	// Set up thread_data_param
    thr_data->mutex 				= mutex;
    thr_data->wait_to_obtain_ms 	= wait_to_obtain_ms;
    thr_data->wait_to_release_ms 	= wait_to_release_ms;
    
    int rc = pthread_create( thread, NULL, threadfunc, ( void * ) thr_data );
    
    if ( rc != 0 ) {
    	DEBUG_LOG( "Failed to create thread, error was %d \n", rc );
    	thr_data->thread_complete_success = false;
    	return false;
    }
	
	
    return true;
}

