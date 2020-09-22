
.PHONY: _all
_all: all

r_pkgs := \
	digest_0.6.25 \
	RPostgreSQL_0.6-2

r_pkgs_dl := $(patsubst %, 3rdparty/download/%.tar.gz, $(r_pkgs))

$(r_pkgs_dl): 3rdparty/download/%.tar.gz:
	mkdir -p 3rdparty/download/
	wget https://cran.r-project.org/src/contrib/$*.tar.gz -O $@

$(patsubst %, 3rdparty/r_packages/%, $(r_pkgs)): 3rdparty/r_packages/%: 3rdparty/download/%.tar.gz
	mkdir -p 3rdparty/r_packages/
  # get package name (without version string) and test if folder exists
	test -d $(addprefix 3rdparty/r_packages/, $(firstword $(subst _, , $*))) \
		|| Rscript -e 'options(warn = 2); install.packages("3rdparty/download/$*.tar.gz", lib="3rdparty/r_packages/", repos=NULL)'

$(r_pkgs): %: 3rdparty/r_packages/%
	echo $(firstword $(subst _, , $@))


all: $(r_pkgs)

.PHONY: download
download: $(r_pkgs_dl)

dlclean: 
	$(RM) 3rdparty/download/*.tar.gz

clean:
	$(RM) -r 3rdparty/r_packages/*