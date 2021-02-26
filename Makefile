CC = gcc
CPPFLAGS =
CFLAGS = -Wall -Wextra -pedantic -std=c99
LDFLAGS =
LDLIBS =

TARGET_BMP = echo_bmp
TARGET_DIFF = diff_bmp
BUILD_DIR = ./build

SRC_BMP = bmp.c
OBJ_BMP = $(SRC_BMP:%.c=$(BUILD_DIR)/%.o)
DEP_BMP = $(OBJ_BMP:%.o=%.d)

SRC_DIFF = diff.c
OBJ_DIFF = $(SRC_DIFF:%.c=$(BUILD_DIR)/%.o)
DEP_DIFF = $(OBJ_DIFF:%.o=%.d)

.PHONY: all bmp diff run clean

all: bmp diff

bmp: $(BUILD_DIR)/$(TARGET_BMP)

diff: $(BUILD_DIR)/$(TARGET_DIFF)

run: all
	$(BUILD_DIR)/$(TARGET_BMP) data/foo.bmp > foo.txt
	$(BUILD_DIR)/$(TARGET_BMP) data/bar.bmp > bar.txt
	#$(BUILD_DIR)/$(TARGET_DIFF) foo.txt bar.txt > diff.txt
	./diff.pl foo.txt bar.txt
	rm foo.txt bar.txt

clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -MMD -o $@ $<

$(BUILD_DIR)/$(TARGET_BMP): $(OBJ_BMP)
	mkdir -p $(BUILD_DIR)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(BUILD_DIR)/$(TARGET_DIFF): $(OBJ_DIFF)
	mkdir -p $(BUILD_DIR)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

-include $(DEP_BMP)
-include $(DEP_DIFF)
