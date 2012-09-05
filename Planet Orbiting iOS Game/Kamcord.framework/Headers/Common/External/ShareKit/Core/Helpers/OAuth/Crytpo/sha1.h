
// From http://www.mirrors.wiretapped.net/security/cryptography/hashes/sha1/sha1.c

typedef struct {
    unsigned long state[5];
    unsigned long count[2];
    unsigned char buffer[64];
} KC_SHA1_CTX;

extern void KC_SHA1Init(KC_SHA1_CTX* context);
extern void KC_SHA1Update(KC_SHA1_CTX* context, unsigned char* data, unsigned int len);
extern void KC_SHA1Final(unsigned char digest[20], KC_SHA1_CTX* context);
