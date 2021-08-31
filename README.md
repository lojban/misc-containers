This is the containerized service infrastructure for various
miscellaneous, static, and old bits of the lojban.org
infrastructure; it's the webserver that catches everything not
caught by other subdomains.

This is an LBCS instance (see https://github.com/lojban/lbcs/ ),
which is why a bunch of things in here are symlinks off into
apparently empty space; you have to have LBCS installed in
/opt/lbcs/ for them to work.

That's also where the docs on how to like start and stop the service
and so on are.

NOTE: The data structure is *NOT* like other LBCS instances, as all
the containers mount data/ in the main directory.  This also means
that there's a special fcontext rule for this user:

        sudo semanage fcontext -a -t container_file_t '/home/spdrata/misc-containers/data(/.*)?' 
