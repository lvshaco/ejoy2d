#include <stdint.h>
#include <stdio.h>

struct sp_entry {
    const char *name;
    uint8_t nsz;
    uint32_t offset;
    uint32_t bodysz;
};

struct sp_entryv {
    int c;
    struct sp_entry *v;
};

void sp_entryv_init(struct sp_entryv *v);
void sp_entryv_fini(struct sp_entryv *v);
int sp_lentryv(FILE *fp, struct sp_entryv *v);
int sp_lentry(FILE *fp, struct sp_entry *e);

char *sp_unpack(const char *pack, const char *name, char **p, size_t *size);
int sp_pack(const char *pack, char **list, size_t n);

char *sp_encrypt(char *buf, size_t sz, const char *key, size_t keylen);
char *sp_decrypt(char *buf, size_t sz, size_t *osz);
