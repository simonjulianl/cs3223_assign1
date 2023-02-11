CPP=gcc
OPTS=-g -Wall
LIBS=-lresolv -ldl -lm

# Modify SRC_DIR as necessary
SRC_DIR=$(HOME)/postgresql-15.0

INCLUDE=-I$(SRC_DIR)/src/include     

freelist-lru.o: freelist-lru.c
	$(CPP) $(OPTS) $(INCLUDE) -c -o freelist-lru.o freelist-lru.c

clean:
	rm -f *.o

lru: copylru pgsql

clock: copyclock pgsql

copylru:
	cp freelist-lru.c $(SRC_DIR)/src/backend/storage/buffer/freelist.c
	cp bufmgr.c $(SRC_DIR)/src/backend/storage/buffer/bufmgr.c

copyclock:
	cp freelist.original.c $(SRC_DIR)/src/backend/storage/buffer/freelist.c
	cp bufmgr.original.c $(SRC_DIR)/src/backend/storage/buffer/bufmgr.c

# error regarding utils/errcodes.h => https://stackoverflow.com/questions/68379786/building-postgres-from-source-throws-utils-errcodes-h-file-not-found-when-ca
pgsql:
	unset MAKELEVEL && unset MAKEFLAGS && unset MFLAGS && cd $(SRC_DIR) && make && make install

compare: SHELL := /bin/bash
compare:
	for i in {1..9}; \
	do \
		diff "testresults/result-$${i}.txt" "testresults-lru-soln/result-$${i}.txt"; \
	done

