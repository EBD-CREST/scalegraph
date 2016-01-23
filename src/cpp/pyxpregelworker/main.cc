#include <Python.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "shmem.h"
#include "x10xpregeladapter.h"

int
main(int argc, char** argv) {

    if (argc < 4) {
        fprintf(stderr, "Usage: pyxpregelworker <place id> <thread id> <num threads>\n");
        return 1;
    }

    X10XPregelAdapterInitialize();
    Py_Initialize();
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('/Users/tosiyuki/EBD/scalegraph-dev/src/python/scalegraph')");

    int place_id = atoi(argv[1]);
    int thread_id = atoi(argv[2]);
    int num_threads = atoi(argv[3]);

    Shmem::placeId = place_id;
    Shmem::threadId = thread_id;
    Shmem::numThreads = num_threads;
    
    PyObject* pymain = PyImport_AddModule("__main__");
    PyObject* globals = PyModule_GetDict(pymain);
    PyObject* locals = PyDict_New();
    
    Shmem::MMapShmemProperty();
    Shmem::DisplayShmemProperty();
    Shmem::ReadShmemProperty(locals);

    PyObject* result = PyRun_String("import xpregelworker\n"
                                    "xpregelworker.run()\n",
                                    Py_file_input, globals, locals);

    if (result == NULL) {
        PyObject *type;
        PyObject *value;
        PyObject *traceback;

        PyErr_Fetch(&type, &value, &traceback);
        PyErr_NormalizeException(&type, &value, &traceback);

        PyObject* pystr = PyObject_Str(value);
        PyObject* tmp = PyUnicode_AsEncodedString(pystr, "ASCII", "strict");
        const char* str = PyBytes_AS_STRING(tmp);
        fprintf(stderr, "pyxpregelworker: %s\n", str);
    }
    exit(0);
    
#if 0
    size_t namelen = 128;
    char* name = new char[namelen];

    snprintf(name, namelen, "/pyxpregel.%s", argv[1]);
    int shmfd = shm_open(name, O_RDONLY);
    if (shmfd < 0) {
        perror("shm_open");
    }
    
    struct stat fs;
    fstat(shmfd, &fs);
    size_t shmemlen = fs.st_size;
    fprintf(stderr, "%s opened, size = %lu\n", name, shmemlen);
    void* shmem = mmap(NULL, shmemlen, PROT_READ, MAP_SHARED, shmfd, 0);

    int place_id = atoi(argv[1]);
    int thread_id = atoi(argv[2]);

    long long* array = static_cast<long long*>(shmem);
    bool flag = true;
    for (int i = 0; i < 10000; i++) {
        if (array[i] != (place_id + 1) * i) {
            flag = false;
            break;
        }
    }

    if (flag) {
        fprintf(stderr, "Child %d:%d OK\n", place_id, thread_id);
    } else {
        fprintf(stderr, "Child %d:%d BAD\n", place_id, thread_id);
    }
#endif
    
    return 0;
}
