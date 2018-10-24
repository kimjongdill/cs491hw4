#include <assert.h>
#include <stdint.h>
#include <numa.h>
#include <pthread.h>

#include "benchmark_list.h"

typedef struct node {
	int value;
	struct node *next;
        pthread_spinlock_t lock;
} node_t;

typedef struct list {
	node_t *head;
} list_t;

list_t *list;

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

inline void init_lock(pthread_spinlock_t* lock)
{
  pthread_spin_init(lock, PTHREAD_PROCESS_SHARED);
  return;
}

void *list_global_init(int init_size, int value_range)
{
	node_t *node;
	int i;

	list = (list_t *)malloc(sizeof(list_t));
	if (list == NULL)
		return NULL;
	list->head = (node_t *)malloc(sizeof(node_t));

	node = list->head;
	if (node == NULL)
		return NULL;
	node->value = INT_MIN;
	init_lock(&(node->lock));
	
	for (i = 0; i < value_range; i += value_range / init_size) {
		node->next = (node_t *)malloc(sizeof(node_t));
		if (node->next == NULL)
			return NULL;
		node = node->next;
		node->value = i;
		init_lock(&(node->lock));
	}
	
	node->next = (node_t *)malloc(sizeof(node_t));
	if (node->next == NULL)
		return NULL;
	node = node->next;
	node->value = INT_MAX;
	init_lock(&(node->lock));
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
	node_t *prev, *cur, *new_node;
	int val=0;
	uint64_t ret=0;

	pthread_spin_lock(&(list->head->lock));
	
	for (prev = list->head, cur = prev->next; cur != NULL; prev = cur, cur = cur->next)
	{
	  pthread_spin_lock(&(cur->lock));                //Lock the next node
	  if ((val = cur->value) >= key)
			break;
	  pthread_spin_unlock(&(prev->lock));             //Unlock the last node
	}
	ret = (val != key);
	// Insert in middle or end
	if (ret) {
		new_node = (node_t *)malloc(sizeof(node_t));
		assert(new_node != NULL);
		new_node->value = key;
		new_node->next = cur;
		init_lock(&(new_node->lock));
		prev->next = new_node;
	}
	
	pthread_spin_unlock(&(prev->lock));
	if(cur != NULL)
	  pthread_spin_unlock(&(cur->lock));
	return ret;
}

int list_del(int key, pthread_data_t *data)
{
	node_t *prev, *cur;
	int val=0;
	uint64_t ret=0;

	pthread_spin_lock(&(list->head->lock));
	for (prev = list->head, cur = prev->next; cur != NULL; prev = cur, cur = cur->next){
	        pthread_spin_lock(&(cur->lock));
		if ((val = cur->value) >= key)
			break;
		pthread_spin_unlock(&(prev->lock));
	}
	ret = (val == key);
	if (ret){
	   pthread_spin_lock(&(cur->next->lock));
	   prev->next = cur->next;
	   pthread_spin_unlock(&(cur->lock));
	   pthread_spin_destroy(&(cur->lock));
	   free(cur);
	   cur = prev->next;
	}
	
	pthread_spin_unlock(&(prev->lock));
	if(cur != NULL)
	  pthread_spin_unlock(&(cur->lock));

	return ret;
}

int list_find(int key, pthread_data_t *data)
{
	node_t *cur;
	node_t *prev;
	int val=0;
	uint64_t ret=0;
	pthread_spin_lock(&(list->head->lock));

        for (prev = list->head, cur = prev->next; cur != NULL; prev = cur, cur = cur->next){
	  pthread_spin_lock(&(cur->lock));
	  pthread_spin_unlock(&(prev->lock));
	  if ((val = cur->value) >= key)
			break;
	}
	ret = (val == key);
	pthread_spin_unlock(&(cur->lock));
	return ret;
}
