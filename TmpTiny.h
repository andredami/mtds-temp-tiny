#ifndef TMPTINY_H
#define TMPTINY_H

enum{
	NUMBER_OF_NODES=4,
	AM_TMPTINY=6
};
typedef nx_struct TmpRequest_s{
	nx_uint16_t nodeid;
}TmpRequest;

typedef nx_struct TmpMessage_s{
	nx_uint16_t nodeid;
	nx_uint32_t measure;
}TmpMessage;
#endif

