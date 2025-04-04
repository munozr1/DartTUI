# Detect operating system
UNAME_S := $(shell uname -s)

# Set compiler and flags
CC = gcc
CFLAGS = -Wall -fPIC

# Set directories
CURRENT_DIR := $(shell pwd)
SRC_DIR = .
LIB_DIR = $(CURRENT_DIR)/lib

# Create lib directory if it doesn't exist
$(shell mkdir -p $(LIB_DIR))

# Platform specific settings
ifeq ($(UNAME_S),Linux)
    TARGET = libwinsize.so
    SHARED_FLAGS = -shared
endif
ifeq ($(UNAME_S),Darwin)
    TARGET = libwinsize.dylib
    SHARED_FLAGS = -dynamiclib
endif
ifeq ($(OS),Windows_NT)
    TARGET = winsize.dll
    SHARED_FLAGS = -shared
endif

# Full path to target
TARGET_PATH = $(LIB_DIR)/$(TARGET)

# Default target
.PHONY: all clean rebuild
all: $(TARGET_PATH)

# Build the library
$(TARGET_PATH): $(SRC_DIR)/winsize.c
	$(CC) $(CFLAGS) $(SHARED_FLAGS) -o $@ $<

# Clean build artifacts
clean:
	rm -f $(LIB_DIR)/*.{so,dylib,dll}

# Rebuild everything
rebuild: clean all 
