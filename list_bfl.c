#include <assert.h>
#include <stdint.h>
//#include <numa.h>
#include <pthread.h>

#include "benchmark_list.h"

#ifdef MUTEX
#define DECLARELOCK pthread_mutex_t lock
#define READ_LOCK pthread_mutex_lock(&lock)
#define WRITE_LOCK pthread_mutex_lock(&lock)
#define UNLOCK pthread_mutex_unlock(&lock)
#define INIT pthread_mutex_init(&lock, NULL)
#define DESTROY pthread_mutex_destroy(&lock)
#endif
// If locktype defined as mutex
#ifdef SPIN
#define DECLARELOCK pthread_spinlock_t lock
#define READ_LOCK pthread_spin_lock(&lock)
#define WRITE_LOCK pthread_spin_lock(&lock)
#define UNLOCK pthread_spin_unlock(&lock)
#define INIT pthread_spin_init(&lock, PTHREAD_PROCESS_SHARED)
#define DESTROY pthread_spin_destroy(&lock)
#endif
// If locktype is defined in compiler set as spinlock
#ifdef RW
#define DECLARELOCK pthread_rwlock_t lock
#define READ_LOCK pthread_rwlock_rdlock(&lock)
#define WRITE_LOCK pthread_rwlock_wrlock(&lock)
#define UNLOCK pthread_rwlock_unlock(&lock)
#define INIT pthread_rwlock_init(&lock, NULL)
#define DESTROY pthread_rwlock_destroy(&lock)
#endif
// If locktype is defined in compiler set as spinlock



typedef struct node {
	int value;
	struct node *next;
} node_t;

typedef struct list {
	node_t *head;
} list_t;

list_t *list;
DECLARELOCK;

pthread_data_t *alloc_pthread_data(void)
{	
	pthread_data_t *d;
	size_t size = sizeof(pthread_data_t);

	size = CACHE_ALIGN_SIZE(size);

	d = (pthread_data_t *)malloc(size);
	if (d != NULL)
		d->ds_data = NULL;

	return d;
}

void *list_global_init(int init_size, int value_range)
{
	node_t *node;
	int i;
	if(INIT)
	  {
	    printf("\nMutex Lock Failed to Initialize\n");
	    return NULL;
	  }
	list = (list_t *)malloc(sizeof(list_t));
	if (list == NULL)
		return NULL;
	list->head = (node_t *)malloc(sizeof(node_t));

	node = list->head;
	if (node == NULL)
		return NULL;
	node->value = INT_MIN;
	
	for (i = 0; i < value_range; i += value_range / init_size) {
		node->next = (node_t *)malloc(sizeof(node_t));
		if (node->next == NULL)
			return NULL;
		node = node->next;
		node->value = i;
	}
	
	node->next = (node_t *)malloc(sizeof(node_t));
	if (node->next == NULL)
		return NULL;
	node = node->next;
	node->value = INT_MAX;
	node->next = NULL;

	return list;
}

// called once per thread. 
int list_thread_init(pthread_data_t *data, pthread_data_t **sync_data, int nr_threads)
{
	return 0;
}

void list_global_exit(void *list)
{
	//	list_t *l = (list_t *)list;
	// free l->head
}

int list_ins(int key, pthread_data_t *data)
{
  WRITE_LOCK;
  node_t *prev, *cur, *new_node;
	int val=0;
	uint64_t ret=0;
	
	for (prev = list->head, cur = prev->next; cur != NULL; prev = cur, cur = cur->next)
		if ((val = cur->value) >= key)
			break;
	ret = (val != key);
	if (ret) {
		new_node = (node_t *)malloc(sizeof(node_t));
		assert(new_node != NULL);
		new_node->value = key;
		new_node->next = cur;
		prev->next = new_node;
	}
	UNLOCK;
	return ret;
}

int list_del(int key, pthread_data_t *data)
{
  WRITE_LOCK;
	node_t *prev, *cur;
	int val=0;
	uint64_t ret=0;

	for (prev = list->head, cur = prev->next; cur != NULL; prev = cur, cur = cur->next)
		if ((val = cur->value) >= key)
			break;
	ret = (val == key);
	if (ret)
		prev->next = cur->next;

	if (ret)
		free(cur);
	UNLOCK;
	return ret;
}

int list_find(int key, pthread_data_t *data)
{
  READ_LOCK;
  node_t *cur;
	int val=0;
	uint64_t ret=0;

	for (cur = list->head->next; cur != NULL; cur = cur->next)
		if ((val = cur->value) >= key)
			break;
	ret = (val == key);
	UNLOCK;
	return ret;
}
