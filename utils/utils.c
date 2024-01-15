#include <stddef.h>
#include <stdint.h>
void* memcpy(void* dest, const void* src, size_t count) {
    uint8_t* d = (uint8_t*)dest;
    const uint8_t* s = (const uint8_t*)src;

    while (count--) {
        *d++ = *s++;
    }

    return dest;
}

void* memset(void* dest, int value, size_t count) {
    uint8_t* d = (uint8_t*)dest;

    while (count--) {
        *d++ = (uint8_t)value;
    }

    return dest;
}

size_t strlen(const char* str) {
    size_t len = 0;

    while (str[len] != '\0') {
        len++;
    }

    return len;
}

