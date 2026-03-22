/* list.c: List Structure */

#include "list.h"

/* List Functions */

/**
 * Create a List structure.
 *
 * @return  Pointer to new List structure (must be deleted later).
 **/
List *	list_create() {
    // TODO
    return NULL;
}

/**
 * Delete List structure.
 *
 * @param   l       Pointer to List structure.
 * @param   release Whether or not to release the string values.
 **/
void	list_delete(List *l, bool release) {
    // TODO
}

/**
 * Add new Value to back of List structure.
 *
 * @param   l       Pointer to List structure.
 * @param   v       Value to add to back of List structure.
 **/
void    list_append(List *l, Value v) {
    // TODO
}

/**
 * Remove Value at specified index from List structure.
 *
 * @param   l       Pointer to List structure.
 * @param   index   Index of Value to remove from List structure.
 *
 * @return  Value at index in List structure (-1 if index is out of bounds).
 **/
Value   list_pop(List *l, size_t index) {
    // TODO
    return (Value)-1L;
}

/* vim: set sts=4 sw=4 ts=8 expandtab ft=c: */
