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

#ifndef __TYPE_H
#define __TYPE_H

class Type {
public:
    enum X10Primitive {
        None		= 0,
        Boolean     = 1,
        Byte		= 2,
        Short		= 3,
        Int         = 4,
        Long		= 5,
        Float		= 6,
        Double      = 7,
        UByte		= 8,
        UShort      = 9,
        UInt		= 10,
        ULong		= 11,
        Char		= 12,
        String      = 13,
        Date		= 14,
        TypeCount	= 15
    };

    static size_t SizeOf(int);
    static PyObject* PyFormat(int);
    
};

#endif
