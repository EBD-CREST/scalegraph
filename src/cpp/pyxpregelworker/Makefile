
# INCLUDE := -I/path/to/sx10/x10.runtime/src-cpp

PROG := pyxpregelworker
SRCS := main.cc shmem.cc type.cc x10xpregeladapter.cc
OBJS := $(SRCS:%.cc=%.o)
DEPS := $(SRCS:%.cc=%.d)
CXXFLAGS = `python3-config --cflags`
LDFLAGS = `python3-config --ldflags`
CXX = g++

all: $(PROG)

-include	$(DEPS)

$(PROG): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

.cc.o:
	$(CXX) $(INCLUDE) $(CXXFLAGS) -MMD -MP -c $<

.PHONY: clean
	$(RM) $(PROG) $(OBJS)
