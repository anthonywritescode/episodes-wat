EPISODES = $(wildcard [0-9][0-9]*)
EPISODES_MAKE = $(patsubst %,make-%,$(EPISODES))

all: index.htm $(EPISODES_MAKE)

venv: requirements.txt
	rm -rf venv
	virtualenv venv -ppython3.6
	venv/bin/pip install -rrequirements.txt
	venv/bin/pre-commit install -f --install-hooks

index.htm: README.md make_index.py venv
	venv/bin/python make_index.py

%/assets:
	mkdir -p $@
%/assets/_app.scss: | %/assets
	cd $*/assets && ln -s ../../assets/_app.scss .
%/assets/_theme.scss: | %/assets
	cd $*/assets && ln -s ../../assets/_theme.scss .

.PHONY: make-%
make-%: %/assets/_app.scss %/assets/_theme.scss venv
	cd $* && ../venv/bin/markdown-to-presentation run-build

push: venv
	venv/bin/markdown-to-presentation push index.htm */index.htm */build

clean:
	rm -rf */.mtp venv */build */index.htm
