# Built from the directory deploy.sh stages, not from the repo root:
#
#   bin/blimp            static x86_64-linux-musl interpreter
#   bin/BLIMP_COMMIT     the blimp commit it was built from
#   blimp_site/          _build/site.blimp, assets/, data/
#   priv/static/         posts/, images/, favicon.ico, robots.txt
#
# The layout matches the repo's, so the paths in main.blimp
# ("../priv/static/posts") work unchanged in both places.
FROM alpine:3.20
COPY bin/blimp /usr/local/bin/blimp
COPY bin/BLIMP_COMMIT /app/BLIMP_COMMIT
COPY priv/static /app/priv/static
COPY blimp_site /app/blimp_site
WORKDIR /app/blimp_site
EXPOSE 4100
# One process: `--serve` boots the site and ticks it forever. The control
# socket is a prompt on the running site, for whoever can exec into the
# container:  docker exec -it blog-blimp-blog-1 blimp --attach site.sock
CMD ["blimp", "--serve", "_build/site.blimp", "--tick", "site <- :tick", "--control", "site.sock"]
