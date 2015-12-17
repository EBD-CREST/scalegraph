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

#include <x10aux/config.h>
//#include <org/scalegraph/io/NativeOSFile.h>
#include "NativePythonIntegrate.h"

namespace org { namespace scalegraph { namespace python {

NativePythonIntegrate NativePythonIntegrate::_make() {
    NativePythonIntegrate ret;
    ret._constructor();
    return ret;
}

void NativePythonIntegrate::_constructor() {
    Py_Initialize();
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append(\".\")");
}

void NativePythonIntegrate::test() {
    PyRun_SimpleString("from time import time,ctime\n"
                       "print('Today is', ctime(time()))\n"
                       "sys.stdout.flush()\n");
}

RTT_CC_DECLS0(NativePythonIntegrate, "org.scalegraph.python.NativePythonIntegrate", x10aux::RuntimeType::class_kind)

}}} // namespace org { namespace scalegraph { namespace python {
