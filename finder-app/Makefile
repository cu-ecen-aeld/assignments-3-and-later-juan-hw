# Compiler options
CC := gcc
CROSS_COMPILE ?=
CFLAGS :=
LDFLAGS :=

# Source files
SRC := writer.c
OBJ := $(SRC:.c=.o)
TARGET := writer

# Default target to build the application
default: $(TARGET)

# Rule to build the application
$(TARGET): $(OBJ)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

# Rule to compile source files
%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c -o $@ $<

# Clean target to remove generated files
clean:
	rm -f $(TARGET) $(OBJ)

