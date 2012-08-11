DEMO_SRC_DIR := ./google-authenticator/libpam
DEMO_BIN_DST := ./google-authenticator-demo

all: submodules $(DEMO_BIN_DST)

submodules:
	git submodule update --init

$(DEMO_BIN_DST):
	make -C $(DEMO_SRC_DIR) demo
	cp $(DEMO_SRC_DIR)/demo $(DEMO_BIN_DST)

clean:
	rm $(DEMO_BIN_DST)
	make -C $(DEMO_SRC_DIR) clean
