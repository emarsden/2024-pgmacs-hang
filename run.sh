# Author: Eric Marsden <eric.marsden@risk-engineering.org>
#
# To reproduce a "mostly hung" Emacs in which Emacs is mostly unresponsive to Ctrl-G, and even
# unkillable using Ctrl-C from the console in some cases. Backtrace in gdb shows pselect64_syscall().
#
# Attaching to process 35858
# [New LWP 35868]
# [New LWP 35867]
# [New LWP 35866]
# [New LWP 35864]
# [New LWP 35863]
# [Thread debugging using libthread_db enabled]
# Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
# 0x00007fdec3f97621 in pselect64_syscall (nfds=16, readfds=0x7ffd36caf870, writefds=0x7ffd36caf8f0, exceptfds=0x0, timeout=<optimized out>, sigmask=<optimized out>) at ../sysdeps/unix/sysv/linux/pselect.c:34

# warning: 34	../sysdeps/unix/sysv/linux/pselect.c: Aucun fichier ou dossier de ce nom
# (gdb) bt
# #0  0x00007fdec3f97621 in pselect64_syscall (nfds=16, readfds=0x7ffd36caf870, writefds=0x7ffd36caf8f0, exceptfds=0x0, timeout=<optimized out>, sigmask=<optimized out>) at ../sysdeps/unix/sysv/linux/pselect.c:34
# #1  __pselect (nfds=16, readfds=0x7ffd36caf870, writefds=0x7ffd36caf8f0, exceptfds=0x0, timeout=<optimized out>, sigmask=<optimized out>) at ../sysdeps/unix/sysv/linux/pselect.c:56
# #2  0x0000560f012403e5 in ??? ()
# #3  0x0000560f01240b73 in ??? ()
# #4  0x0000560f01267fd6 in ??? ()
# #5  0x0000560f0121739d in ??? ()
# #6  0x0000560f01219490 in ??? ()
# #7  0x0000560f011b78dc in ??? ()


# At an Emacs Lisp level, the hang is related to reading from a network socket. 
#
#
# To reproduce: in Emacs, type RET with point on the "data_src" table name, which will show the
# content of that table. Then type "W foobles RET" (the "foobles" is typed into the minibuffer). This
# applies an invalid "where filter" on the current SQL table, which generates an error from
# PostgreSQL, and Emacs hangs reading the content of this error from the network.
#
# PostgreSQL is used here in a Docker/Podman container for convenience; the same issue
# arises with a local installation.
#
# The Emacs Lisp files used here are copied unmodified from the pg-el library and from PGmacs
#    https://github.com/emarsden/pg-el
#    https://github.com/emarsden/pgmacs

echo Starting PostgreSQL in Docker
podman run --rm --name pgsql \
   --publish 5426:5426 \
   -e POSTGRES_DB=pgeltestdb \
   -e POSTGRES_USER=pgeltestuser \
   -e POSTGRES_PASSWORD=pgeltest \
   -e PGPORT=5426 \
   -d docker.io/library/postgres:17-alpine
sleep 5
emacs -Q -l peg.el -l pg.el -l pgmacstbl.el -l pgmacs.el -l setup.el --eval '(pgmacs-open-uri "postgresql://pgeltestuser:pgeltest@localhost:5426/pgeltestdb")'

# cleanup
podman stop pgsql



# podman run --rm --name pgsql \
# 	  --publish 5778:5778 \
# 	   -e POSTGRES_USER=pgeltestuser \
# 	   -e POSTGRES_PASSWORD=pgeltest \
# 	   -e PGPORT=5778 \
# 	   -d docker.io/aa8y/postgres-dataset:latest
# # This docker image imports a lot of data on startup 
# sleep 120
# emacs -Q -l peg.el -l pg.el -l pgmacstbl.el -l pgmacs.el --eval '(pgmacs-open-string "dbname=usda hostname=localhost port=5778 user=pgeltestuser password=pgeltest")'
