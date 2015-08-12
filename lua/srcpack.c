#include "srcpack.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <errno.h>

#define HEAD_OFFSET 16

#define sread(ptr, size, fp) do { \
    int r = fread(ptr, size, 1, fp); \
    if (r<=0) \
        goto err; \
} while (0)

#define pread(ptr,size,o,osz) \
    if (size>=osz) { \
        memcpy(o, ptr, osz); \
        ptr += osz; \
        size -= osz; \
    } else { \
        goto err; \
    }

#define pskip(ptr,size,osz) \
    if (size>=osz) { \
        ptr += osz; \
        size -= osz; \
    } else { \
        goto err; \
    }

static void
_randhk(char hk[4]) {
    int i;
    for (i=0;i<4;++i) {
        hk[i] = rand()%64+192;
    }
}

static size_t
_randkey(char key[32]) {
    int n = rand()%5+10;
    int i;
    for (i=0;i<n;++i) {
        key[i] = rand()%64+192;
    }
    return n;
}

void
xor(char *buf, int sz, const char *key, int kl) {
    int i;
    for (i=0;i<sz;++i) {
        buf[i] = buf[i]^key[i%kl];
    }
}

char *
sp_encrypt(char *buf, size_t sz, const char *key, size_t keylen) {
    char *body = buf;
    size_t i;
    for (i=0;i<sz;++i) {
        body[i] = body[i]^key[i%keylen];
    }
    for (i=0;i<sz-1;i+=2) {
        char tmp = body[i];
        body[i] = body[i+1];
        body[i+1] = tmp;
    }
    return body;
}

char *
sp_decrypt(char *buf, size_t sz, size_t *osz) {
    char keylen = buf[0];
    if (keylen < 0) {
        return NULL;
    }
    char *key = &buf[1];
    char *body = &buf[keylen+1];
    if ((int)sz <= 1+keylen) {
        return NULL;
    }
    sz -=1+keylen;
    size_t i;
    for (i=0;i<sz-1;i+=2) {
        char tmp = body[i];
        body[i] = body[i+1];
        body[i+1] = tmp;
    }
    for (i=0; i<sz; ++i) {
        body[i] = body[i]^key[i%keylen];
    }
    *osz = sz;
    return body;
}

void 
sp_entryv_init(struct sp_entryv *v) {
    v->c = 0;
    v->v = NULL;
}

void 
sp_entryv_fini(struct sp_entryv *v) {
    if (v->v == NULL)
        return;
    int i;
    for (i=0;i<v->c;++i)
        free((void*)v->v[i].name);
    free(v->v);
    v->v = NULL;
    v->c = 0;
}

int
sp_lentryv(FILE *fp, struct sp_entryv *v) {
    uint32_t magic;
    uint32_t headsz;
    uint32_t nentry;
    char hk[4];
    sread(&magic, 4, fp);
    sread(&headsz, 4, fp);
    sread(&nentry, 4, fp);
    sread(hk, 4, fp);
    if (headsz==0 || nentry==0) {
        return 1;
    } 
    v->c = nentry;
    v->v = malloc(sizeof(v->v[0])*nentry);
    memset(v->v, 0, sizeof(v->v[0])*nentry);
    int offset = headsz+HEAD_OFFSET;
    uint32_t i;
    for (i=0;i<nentry;++i) {
        struct sp_entry *e = &v->v[i];
        sread(&e->nsz,1,fp);
        char *name = malloc(e->nsz+1);
        sread(name,e->nsz,fp);
        name[e->nsz] = '\0';
        xor(name, e->nsz, hk,4);
        e->name = name;
        sread(&e->offset,4,fp);
        sread(&e->bodysz,4,fp);
        e->offset += offset;
    }
    return 0;
err:
    free(v);
    return 1;
}

int 
sp_lentry(FILE *fp, struct sp_entry *e) {
    size_t namesz = strlen(e->name);
    if (namesz == 0) {
        return 1;
    }
    char *head = NULL;
    char name[namesz];
    uint32_t magic;
    uint32_t headsz;
    uint32_t nentry;
    char hk[4];
    sread(&magic, 4, fp);
    sread(&headsz, 4, fp);
    sread(&nentry, 4, fp);
    sread(hk, 4, fp);
    if (headsz==0 || nentry==0) { 
        return 1;
    }
    head = malloc(headsz);
    sread(head, headsz, fp);
  
    bool found = false;
    memcpy(name, e->name, namesz);
    xor(name, namesz, hk,4);

    char *p = head;
    int sz = headsz;
    while (sz > 0) {
        uint8_t nsz;
        pread(p, sz, &nsz, 1);
        char *cn = p;
        pskip(p, sz, nsz);

        if (namesz == nsz) {
            if (memcmp(cn, name, nsz)==0) {
                pread(p, sz, &e->offset,4);
                pread(p, sz, &e->bodysz,4);
                e->offset += headsz+HEAD_OFFSET;
                e->nsz = nsz;
                found = true;
                break;
            }
        }
        pskip(p, sz, 8);
    }
    free(head);
    return !found;
err:
    free(head);
    return 1;
}

char *
sp_unpack(const char *pack, const char *name, char **p, size_t *size) {
    FILE *fp = fopen(pack,"r");
    if (fp == NULL) { 
        return NULL;
    }
    struct sp_entry e;
    e.name = name;
    if (sp_lentry(fp, &e)) { 
        return NULL;
    }
    if (e.bodysz==0) { 
        return NULL;
    }
    int r = fseek(fp, e.offset, SEEK_SET);
    if (r!=0) {
        return NULL;
    }
    char *body = malloc(e.bodysz);
    sread(body, e.bodysz, fp);

    //*p = body;*size=e.bodysz;
    *p = sp_decrypt(body, e.bodysz, size);
    if (*p == NULL)
        goto err;
    return body;
err:
    free(body);
    return NULL;
}

int
sp_pack(const char *pack, char **l, size_t n) {
    FILE *fp = fopen(pack, "w");
    if (fp == NULL) {
        return 1;
    }
    n = n/2;
    uint32_t magic = 0;
    uint32_t headsz = 0;
    struct sp_entry enl[n];
    size_t i;
    for (i=0;i<n;++i) {
        const char *name = l[i*2+1];
        enl[i].name = name;
        enl[i].nsz = strlen(name);
        headsz += enl[i].nsz;
    }
    headsz += n*9; 
    fwrite(&magic, 4, 1, fp);
    fwrite(&headsz, 4, 1, fp);
    fwrite(&n, 4, 1, fp);
    char hk[4];
    _randhk(hk);
    fwrite(hk, 4, 1, fp);
    for (i=0;i<n;++i) {
        uint8_t len = enl[i].nsz;
        fwrite(&len, 1, 1, fp);
        char *name = malloc(len);
        memcpy(name, enl[i].name, len);
        xor(name, len, hk, 4);
        fwrite(name, len, 1, fp);
        fseek(fp, 8, SEEK_CUR);
    }
    char key[32];
    size_t offset = 0;
    char *body = NULL;
    for (i=0; i<n; ++i) { 
        FILE *cf = fopen(l[i*2],"r");
        if (cf==NULL) {
            goto err;
        }
        fseek(cf,0,SEEK_END);
        size_t size = ftell(cf);
        if (size == 0) {
            continue;
        }
        fseek(cf,0,SEEK_SET);
        body = malloc(size);
        sread(body, size, cf);

        size_t keylen = _randkey(key);
        char *enc = sp_encrypt(body, size, key, keylen);
        assert(enc);
        fwrite(&keylen,1,1,fp);
        fwrite(key,keylen,1,fp);
        fwrite(enc,size,1,fp);
        size = size+1+keylen;

        //size_t keylen = _randkey(key);
        //char *enc = body;
        //assert(keylen);
        //assert(enc);
        //fwrite(enc,size,1,fp);

        free(body);
        body = NULL;
        fclose(cf);
        enl[i].offset=offset;
        enl[i].bodysz=size;
        offset += size;
    }
    offset = HEAD_OFFSET;
    for (i=0;i<n;++i) {
        offset += 1+enl[i].nsz;
        fseek(fp, offset, SEEK_SET);
        fwrite(&enl[i].offset, 4, 1, fp);
        fwrite(&enl[i].bodysz, 4, 1, fp);
        offset += 8;
    }
    fclose(fp);
    return 0;
err:
    free(body);
    return 1;
}
