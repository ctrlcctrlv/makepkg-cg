#include "makepkg-cg-prio.h"

SEC("sk_skb/stream_parser")
extern int makepkg_cg_prio(struct __sk_buff *skb) {
    skb->priority = 7;
    return skb->len;
}
