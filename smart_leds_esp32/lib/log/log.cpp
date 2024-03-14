
#include "log.h"

struct {

    SemaphoreHandle_t mutex;
    bool ready = false;

    char* buffer = nullptr;
    size_t capacity = 0;
    size_t length = 0;

} qlog_context;

void qlog_setup(size_t capacity) {

    if(qlog_context.ready) return;

    if(capacity < 256) {
        capacity = 256;
    }

    qlog_context.mutex = xSemaphoreCreateMutex();

    qlog_context.capacity = capacity;
    qlog_context.length = 0;

    qlog_context.buffer = new char[qlog_context.capacity];
    memset(qlog_context.buffer, 0, qlog_context.capacity);

    qlog_context.ready = true;

}

void qlog_write(const char* format, ...) {

    if(!qlog_context.ready) return;

    if(xSemaphoreTake(qlog_context.mutex, portMAX_DELAY) == pdTRUE) {
        
        va_list args;
        va_start(args, format);

        char* start = qlog_context.buffer + qlog_context.length;
        int available = qlog_context.capacity - qlog_context.length;

        if(available < 32) {
            qlog_context.buffer[0] = 0;
            qlog_context.length = 0;

            start = qlog_context.buffer;
            available = qlog_context.capacity;
        }

        int n = vsnprintf(start, available, format, args);
        qlog_context.length += n;

        if(n + 1 > available) {
            qlog_context.buffer[0] = 0;
            qlog_context.length = 0;

            start = qlog_context.buffer;
            available = qlog_context.capacity;

            n = vsnprintf(start, available, format, args);
            qlog_context.length = n;
        }

        #ifdef SERIAL_DEBUG
        Serial.write(start, n);
        #endif

        va_end(args);
        xSemaphoreGive(qlog_context.mutex);
    }

}

std::string qlog_get_logs() {
    
    std::string logs = "";
    if(!qlog_context.ready) return logs;

    if(xSemaphoreTake(qlog_context.mutex, portMAX_DELAY) == pdTRUE) {
        logs = std::string(qlog_context.buffer, qlog_context.length);
        xSemaphoreGive(qlog_context.mutex);
    }

    return logs;
}

void qlog_clear() {

    if(!qlog_context.ready) return;

    if(xSemaphoreTake(qlog_context.mutex, portMAX_DELAY) == pdTRUE) {
        qlog_context.buffer[0] = 0;
        qlog_context.length = 0;
        xSemaphoreGive(qlog_context.mutex);
    }

}
