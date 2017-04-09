EPISODES = $(wildcard [0-9][0-9]*)
EPISODES_SCSS_APP = $(patsubst %,%/assets/_app.scss,$(EPISODES))
EPISODES_SCSS_THEME = $(patsubst %,%/assets/_theme.scss,$(EPISODES))

all: index.htm make-episodes

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

make-episodes: $(EPISODES_SCSS_APP) $(EPISODES_SCSS_THEME) venv
make-episodes:
	echo -n $(EPISODES) | \
		xargs -d' ' --replace bash -c ' \
			cd {} && ../venv/bin/markdown-to-presentation run-build \
		'

clean:
	rm -rf */.mtp venv */build */index.htm
