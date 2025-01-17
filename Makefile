# sequential building
MAKEFLAGS := -j 1

.PHONY: _all
_all: all

# packages
r_pkgs := \
	digest_0.6.25 \
	jsonlite_1.7.1 \
	RPostgreSQL_0.6-2 \
	DBI_1.1.0

# package dependencies
.PHONY:
3rdparty/r_packages/RPostgreSQL_0.6-2_deps: 3rdparty/r_packages/DBI_1.1.0

#-------------------------------------------------------------------------------

# dummy deps
r_pkg_deps := $(addsuffix _deps, $(patsubst %, 3rdparty/r_packages/%, $(r_pkgs)))
.PHONY: $(r_pkg_deps)
$(r_pkg_deps): 

# download
r_pkgs_dl := $(patsubst %, 3rdparty/download/%.tar.gz, $(r_pkgs))
$(r_pkgs_dl): 3rdparty/download/%.tar.gz:
	mkdir -p 3rdparty/download/
	wget https://cran.r-project.org/src/contrib/$*.tar.gz -O $@

# install
r_pkgs_isnt := $(patsubst %, 3rdparty/r_packages/%, $(r_pkgs))
.PHONY: $(r_pkgs_isnt)
$(r_pkgs_isnt): 3rdparty/r_packages/%: 3rdparty/download/%.tar.gz 3rdparty/r_packages/%_deps
	mkdir -p 3rdparty/r_packages/
  # get package name (without version string) and test if folder exists
	test -d $(addprefix 3rdparty/r_packages/, $(firstword $(subst _, , $*))) \
		|| Rscript -e 'options(warn = 2); install.packages("3rdparty/download/$*.tar.gz", lib="3rdparty/r_packages/", repos=NULL)'

$(r_pkgs): %: 3rdparty/r_packages/%

#-------------------------------------------------------------------------------

all: $(r_pkgs)

.PHONY: download
download: $(r_pkgs_dl)

dlclean: 
	$(RM) 3rdparty/download/*.tar.gz

clean:
	$(RM) -r 3rdparty/r_packages/*