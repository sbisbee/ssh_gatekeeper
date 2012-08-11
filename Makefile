DEMO_SRC_DIR := ./google-authenticator/libpam
DEMO_BIN_DST := google-authenticator-demo

INSTALL_DIR := /usr/local/bin
INSTALL_FILES := ssh_gatekeeper.sh $(DEMO_BIN_DST)

all: submodules $(DEMO_BIN_DST)

submodules:
	git submodule update --init

$(DEMO_BIN_DST):
	make -C $(DEMO_SRC_DIR) demo
	cp $(DEMO_SRC_DIR)/demo $(DEMO_BIN_DST)

install: all
	@for file in $(INSTALL_FILES); do \
		cp $$file $(INSTALL_DIR); \
		chmod +x $(INSTALL_DIR)/$$file; \
	done

uninstall:
	for file in $(INSTALL_FILES); do \
		rm $(INSTALL_DIR)/$$file; \
	done

clean:
	rm $(DEMO_BIN_DST)
	make -C $(DEMO_SRC_DIR) clean
