#include <optimsoc-baremetal.h>
#include <optimsoc-runtime.h>
#include <optimsoc-mp.h>

#include "gzll.h"

#include "../include/gzll-apps.h"

#include <stdio.h>

uint32_t gzll_rank;
optimsoc_thread_t _gzll_comm_thread;

extern void* _image_gzll_kernel_end;
extern void* _image_gzll_apps_start;
extern void* _image_gzll_apps_end;

struct _gzll_image_layout  _gzll_image_layout
__attribute__((section(".gzll_image_layout"))) = {
        { 'g', 'z', 'l', 'l' }, &_image_gzll_kernel_end,
        &_image_gzll_apps_start, &_image_gzll_apps_end };

void main() {
    if (gzll_swapping()) {
        // TODO: Load pages from memory
    }

    printf("Boot gzll in node %d (%d total)\n", gzll_rank, optimsoc_get_numct());

    // Initialize paging
    gzll_paging_init();

    optimsoc_mp_initialize(0);

    gzll_rank = optimsoc_get_ctrank();

    optimsoc_syscall_handler_set(gzll_syscall_handler);

    optimsoc_runtime_boot();
}

void init() {
    communication_init();

    struct optimsoc_thread_attr attr;
    optimsoc_thread_attr_init(&attr);
    attr.identifier = "comm";
    attr.flags |= OPTIMSOC_THREAD_FLAG_KERNEL;
    optimsoc_thread_create(&_gzll_comm_thread, &communication_thread, &attr);

    gzll_apps_bootstrap();

}
