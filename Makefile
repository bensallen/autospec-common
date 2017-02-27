URL=
PKG_NAME=
AUTOSPEC=python3 ~/autospec/autospec/autospec.py
newpkg:
ifdef PKG_NAME
	$(AUTOSPEC) -n $(PKG_NAME) $(URL)
else
	$(AUTOSPEC) $(URL)
endif
