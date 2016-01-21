/* 
 *  This file is part of the ScaleGraph project (http://scalegraph.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright ScaleGraph Team 2011-2016.
 */

#include <Python.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <string.h>

#include <signal.h>
//#include <sys/wait.h>
#include <gc.h>
#include <pthread.h>

#include <x10aux/config.h>
#include <x10/lang/String.h>
#include <x10/lang/Place.h>
#include <x10/lang/LongRange.h>
#include <x10/lang/VoidFun_0_2.h>
#include <org/scalegraph/util/MemoryChunk.h>
#include <org/scalegraph/exception/PyXPregelException.h>
#include <org/scalegraph/api/NativePyXPregelAdapter.h>
#include <org/scalegraph/api/PyXPregelPipe.h>

extern "C" {
    int GC_get_suspend_signal();
    int GC_get_thr_restart_signal();
}
    
namespace org { namespace scalegraph { namespace api {


static PyObject* x10xpregeladapter_placeid(PyObject* self, PyObject* args) {

    if (!PyArg_ParseTuple(args, ":placeid")) {
        return NULL;
    }
    x10_long here_id = ::x10::lang::Place::_make(::x10aux::here)->FMGL(id);
    return PyLong_FromLong(here_id);
}


static PyMethodDef X10XPregelAdapterMethods[] = {
    {"placeid", x10xpregeladapter_placeid, METH_VARARGS,
     "Return the place id of the runnning process."},
    {NULL, NULL, 0, NULL}
};


static PyModuleDef X10XPregelAdapterModule = {
    PyModuleDef_HEAD_INIT, "x10xpregeladapter", NULL, -1, X10XPregelAdapterMethods,
    NULL, NULL, NULL, NULL
};


static PyObject* PyInit_x10xpregeladapter(void) {
    return PyModule_Create(&X10XPregelAdapterModule);
}


//-----------------------------------------

void NativePyXPregelAdapter::initialize() {
    PyImport_AppendInittab("x10xpregeladapter", &PyInit_x10xpregeladapter);
}

/* exec worker process after fork
 *
 */
::org::scalegraph::api::PyXPregelPipe NativePyXPregelAdapter::fork(x10_long place_id,
                                                                   x10_long thread_id,
                                                                   x10_long idx,
                                                                   ::x10::lang::LongRange i_range) {

    int pipe_stdin[2];
    int pipe_stdout[2];
    int pipe_stderr[2];
    
    if (pipe(pipe_stdin) < 0) {
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("pipe call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    if (pipe(pipe_stdout) < 0) {
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("pipe call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    if (pipe(pipe_stderr) < 0) {
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("pipe call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    sigset_t block, oblock, oblock2;
    struct sigaction sa_sigpwr, sa_sigxcpu;

    //    int sigsuspend = GC_get_suspend_signal();
    //    int sigrestart = GC_get_thr_restart_signal();
    int sigsuspend = SIGUSR1;
    int sigrestart = SIGUSR2;

#if 0
    ::sigaction(sigsuspend, 0, &sa_sigpwr);
    ::sigaction(sigrestart, 0, &sa_sigxcpu);
    sa_sigpwr.sa_flags |= SA_RESTART;
    sa_sigxcpu.sa_flags |= SA_RESTART;
    ::sigaction(sigsuspend, &sa_sigpwr, 0);
    ::sigaction(sigrestart, &sa_sigxcpu, 0);
#endif
    sigemptyset(&block);
    sigaddset(&block, sigsuspend);
    sigaddset(&block, sigrestart);
        for (int k = 21; k < 32; k++) {
            sigaddset(&block, k);
        }
    ::pthread_sigmask(SIG_BLOCK, &block, &oblock);
    ::sigprocmask(SIG_BLOCK, &block, &oblock2);

    fprintf(stderr, "mask signal = %d %d", sigsuspend, sigrestart);
    
    pid_t pid = ::fork();
    if (pid < 0) {

        ::pthread_sigmask(SIG_SETMASK, &oblock, 0);
        ::sigprocmask(SIG_SETMASK, &oblock2, 0);
        
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("fork call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    if (pid == 0) {
        // Child process

        ::close(pipe_stdin[1]);
        ::dup2(pipe_stdin[0], STDIN_FILENO);
        ::close(pipe_stdin[0]);

        ::close(pipe_stdout[0]);
        ::dup2(pipe_stdout[1], STDOUT_FILENO);
        ::close(pipe_stdout[1]);

        ::close(pipe_stderr[0]);
        ::dup2(pipe_stderr[1], STDERR_FILENO);
        ::close(pipe_stderr[1]);

        // do something        
        // (call python closure)

        fprintf(stderr, "Child pid is %d\n", getpid());
        
        size_t arglen = 128;
        char* arg0 = new char[arglen];
        char* arg1 = new char[arglen];
        char* arg2 = new char[arglen];
        snprintf(arg0, arglen, "pyxpregelworker");
        snprintf(arg1, arglen, "%lld", (long long)place_id);
        snprintf(arg2, arglen, "%lld", (long long)thread_id);
        execl("/Users/tosiyuki/EBD/scalegraph-dev/src/cpp/pyxpregelworker/pyxpregelworker",
              arg0, arg1, arg2, 0);
        perror("pyxpregelworker");

        ::_exit(1);
        return ::org::scalegraph::api::PyXPregelPipe::_make();

    } else {
        // Parent process

        ::pthread_sigmask(SIG_SETMASK, &oblock, 0);
        ::sigprocmask(SIG_SETMASK, &oblock2, 0);
        fprintf(stderr, "%d forked %d\n", getpid(), pid);

        ::kill(pid, SIGCONT);
        
        close(pipe_stdin[0]);
        close(pipe_stdout[1]);
        close(pipe_stderr[1]);

        // read pipe_stdout[0] and pipe_stderr[0]
        // and do something

        int status;
        //        ::waitpid(pid, &status, WUNTRACED);
        
        return ::org::scalegraph::api::PyXPregelPipe::_make(pipe_stdin[1],
                                                            pipe_stdout[0],
                                                            pipe_stderr[0]);
    }

}


/*
 * call closure after fork
 */
::org::scalegraph::api::PyXPregelPipe NativePyXPregelAdapter::fork(x10_long place_id,
                                                                   x10_long thread_id,
                                                                   x10_long idx,
                                                                   ::x10::lang::LongRange i_range,
                                                                   ::x10::lang::VoidFun_0_2<x10_long,  ::x10::lang::LongRange>* func) {

    int pipe_stdin[2];
    int pipe_stdout[2];
    int pipe_stderr[2];
    
    if (pipe(pipe_stdin) < 0) {
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("pipe call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    if (pipe(pipe_stdout) < 0) {
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("pipe call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    if (pipe(pipe_stderr) < 0) {
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("pipe call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    sigset_t block, oblock, oblock2;
    struct sigaction sa_sigpwr, sa_sigxcpu;

    //    int sigsuspend = GC_get_suspend_signal();
    //    int sigrestart = GC_get_thr_restart_signal();
    int sigsuspend = SIGUSR1;
    int sigrestart = SIGUSR2;

#if 0
    ::sigaction(sigsuspend, 0, &sa_sigpwr);
    ::sigaction(sigrestart, 0, &sa_sigxcpu);
    sa_sigpwr.sa_flags |= SA_RESTART;
    sa_sigxcpu.sa_flags |= SA_RESTART;
    ::sigaction(sigsuspend, &sa_sigpwr, 0);
    ::sigaction(sigrestart, &sa_sigxcpu, 0);
#endif
    sigemptyset(&block);
    sigaddset(&block, sigsuspend);
    sigaddset(&block, sigrestart);
        for (int k = 21; k < 32; k++) {
            sigaddset(&block, k);
        }
    ::pthread_sigmask(SIG_BLOCK, &block, &oblock);
    ::sigprocmask(SIG_BLOCK, &block, &oblock2);

    fprintf(stderr, "mask signal = %d %d", sigsuspend, sigrestart);
    
    pid_t pid = ::fork();
    if (pid < 0) {

        ::pthread_sigmask(SIG_SETMASK, &oblock, 0);
        ::sigprocmask(SIG_SETMASK, &oblock2, 0);
        
        ::x10aux::throwException(::x10aux::nullCheck( ::org::scalegraph::exception::PyXPregelException::_make(::x10::lang::String::Lit("fork call failed"))));
        return ::org::scalegraph::api::PyXPregelPipe::_make();
    }

    if (pid == 0) {
        // Child process

        ::close(pipe_stdin[1]);
        ::dup2(pipe_stdin[0], STDIN_FILENO);
        ::close(pipe_stdin[0]);

        ::close(pipe_stdout[0]);
        ::dup2(pipe_stdout[1], STDOUT_FILENO);
        ::close(pipe_stdout[1]);

        ::close(pipe_stderr[0]);
        ::dup2(pipe_stderr[1], STDERR_FILENO);
        ::close(pipe_stderr[1]);

        // do something        
        // (call python closure)

        fprintf(stderr, "Child pid is %d\n", getpid());
        
        ::x10::lang::VoidFun_0_2<x10_long,  ::x10::lang::LongRange>::__apply(::x10aux::nullCheck(func), 
                                                                             idx, i_range);

        //size_t size = 10;
        //        x10_long* writebuf = new x10_long[size];
        //        ::write(STDOUT_FILENO, writebuf, size * sizeof(x10_long));
        

        ::_exit(1);
        return ::org::scalegraph::api::PyXPregelPipe::_make();

    } else {
        // Parent process

        ::pthread_sigmask(SIG_SETMASK, &oblock, 0);
        ::sigprocmask(SIG_SETMASK, &oblock2, 0);
        fprintf(stderr, "%d forked %d\n", getpid(), pid);

        ::kill(pid, SIGCONT);
        
        close(pipe_stdin[0]);
        close(pipe_stdout[1]);
        close(pipe_stderr[1]);

        /*
		const char *s = "send from parent to child";
		write(pipe_stdin[1], s, strlen(s));
		close(pipe_stdin[1]);
        */
        
        // read pipe_stdout[0] and pipe_stderr[0]
        // and do something

        int status;
        //        ::waitpid(pid, &status, WUNTRACED);
        
        return ::org::scalegraph::api::PyXPregelPipe::_make(pipe_stdin[1],
                                                            pipe_stdout[0],
                                                            pipe_stderr[0]);
    }

}


NativePyXPregelAdapterProperty NativePyXPregelAdapter::property;
void* NativePyXPregelAdapter::shmemProperty;

void NativePyXPregelAdapter::createShmemProperty(x10_long place_id) {

    size_t namelen = 128;
    char* name = new char[namelen];

    snprintf(name, namelen, "/pyxpregel.place.%lld", place_id);

    ::shm_unlink(name);
    fprintf(stderr, "shm_open %s %d\n", name, O_RDWR|O_CREAT);
    int shmfd = ::shm_open(name, O_RDWR|O_CREAT, 0664);
    if (shmfd < 0) {
        perror("property shm_open");
        _exit(1);
    }
    size_t shmemlen = sizeof(NativePyXPregelAdapterProperty);
    ftruncate(shmfd, shmemlen);
    shmemProperty = mmap(NULL, shmemlen, PROT_READ|PROT_WRITE, MAP_SHARED, shmfd, 0);
    close(shmfd);
}

void NativePyXPregelAdapter::updateShmemProperty() {
    memcpy(shmemProperty, &property, sizeof(NativePyXPregelAdapterProperty));
}


//-----------------------------------------

NativePyXPregelAdapter* NativePyXPregelAdapter::NativePyXPregelAdapter____this__NativePyXPregelAdapter() {
    return this;
}

void NativePyXPregelAdapter::_constructor() {
    this->NativePyXPregelAdapter::__fieldInitializers_NativePyXPregelAdapter();
}

NativePyXPregelAdapter* NativePyXPregelAdapter::_make() {
    NativePyXPregelAdapter* this_ = new (::x10aux::alloc_z< NativePyXPregelAdapter>())  NativePyXPregelAdapter();
    this_->_constructor();
    return this_;
}

void NativePyXPregelAdapter::__fieldInitializers_NativePyXPregelAdapter() {
    //    this->FMGL(strtmp) = (::x10aux::class_cast_unchecked< ::x10::lang::String*>(reinterpret_cast< ::x10::lang::NullType*>(X10_NULL)));
}
const ::x10aux::serialization_id_t NativePyXPregelAdapter::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer( NativePyXPregelAdapter::_deserializer);

void NativePyXPregelAdapter::_serialize_body(::x10aux::serialization_buffer& buf) {
    //    buf.write(this->FMGL(strtmp));
    
}

::x10::lang::Reference*  NativePyXPregelAdapter::_deserializer(::x10aux::deserialization_buffer& buf) {
     NativePyXPregelAdapter* this_ = new (::x10aux::alloc_z< NativePyXPregelAdapter>())  NativePyXPregelAdapter();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void NativePyXPregelAdapter::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    //    FMGL(strtmp) = buf.read< ::x10::lang::String*>();
}

::x10aux::RuntimeType NativePyXPregelAdapter::rtt;
void NativePyXPregelAdapter::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("NativePyXPregelAdapter",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}


}}} // namespace org { namespace scalegraph { namespace api {
