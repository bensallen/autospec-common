URL=
PKG_NAME=

newpkg:
ifdef PKG_NAME
	python3 ~/autospec/autospec/autospec.py -n $(PKG_NAME) $(URL)
else
	python3 ~/autospec/autospec/autospec.py $(URL)
endif
