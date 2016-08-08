//
//  CertificatePinningManager.m
//  Kofax Mobile Demo
//
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "CertificatePinningManager.h"

// Certificate in DER format for
//https://mobiledemo.kofax.com
//https://mobilekta-beta.kofax.com
static const uint8_t MOBILEDEMO_DER_CERTIFICATE[] = {
    0x30,0x82,0x5,0xa2,0x30,0x82,0x4,0x8a,0xa0,0x3,0x2,0x1,0x2,0x2,0x10,0x3f,0xa,0xd0,0xa4,0xb4,0x8,0x86,0x33,0xea,0xf7,0x75,0x93,0x18,0xd6,0x53,0xb3,0x30,0xd,0x6,0x9,0x2a,0x86,0x48,0x86,0xf7,0xd,0x1,0x1,0x5,0x5,0x0,0x30,0x62,0x31,0xb,
    0x30,0x9,0x6,0x3,0x55,0x4,0x6,0x13,0x2,0x55,0x53,0x31,0x21,0x30,0x1f,0x6,0x3,0x55,0x4,0xa,0x13,0x18,0x4e,0x65,0x74,0x77,0x6f,0x72,0x6b,0x20,0x53,0x6f,0x6c,0x75,0x74,0x69,0x6f,0x6e,0x73,0x20,0x4c,0x2e,0x4c,0x2e,0x43,0x2e,0x31,0x30,0x30,0x2e,
    0x6,0x3,0x55,0x4,0x3,0x13,0x27,0x4e,0x65,0x74,0x77,0x6f,0x72,0x6b,0x20,0x53,0x6f,0x6c,0x75,0x74,0x69,0x6f,0x6e,0x73,0x20,0x43,0x65,0x72,0x74,0x69,0x66,0x69,0x63,0x61,0x74,0x65,0x20,0x41,0x75,0x74,0x68,0x6f,0x72,0x69,0x74,0x79,0x30,0x1e,0x17,0xd,
    0x31,0x33,0x30,0x36,0x30,0x35,0x30,0x30,0x30,0x30,0x30,0x30,0x5a,0x17,0xd,0x31,0x36,0x30,0x36,0x30,0x34,0x32,0x33,0x35,0x39,0x35,0x39,0x5a,0x30,0x81,0xb2,0x31,0xb,0x30,0x9,0x6,0x3,0x55,0x4,0x6,0x13,0x2,0x55,0x53,0x31,0xe,0x30,0xc,0x6,0x3,
    0x55,0x4,0x11,0x13,0x5,0x39,0x32,0x36,0x31,0x38,0x31,0xb,0x30,0x9,0x6,0x3,0x55,0x4,0x8,0x13,0x2,0x43,0x41,0x31,0xf,0x30,0xd,0x6,0x3,0x55,0x4,0x7,0x13,0x6,0x49,0x72,0x76,0x69,0x6e,0x65,0x31,0x1f,0x30,0x1d,0x6,0x3,0x55,0x4,0x9,0x13,
    0x16,0x31,0x35,0x32,0x31,0x31,0x20,0x4c,0x61,0x67,0x75,0x6e,0x61,0x20,0x43,0x61,0x6e,0x79,0x6f,0x6e,0x20,0x52,0x64,0x31,0xe,0x30,0xc,0x6,0x3,0x55,0x4,0xa,0x13,0x5,0x4b,0x4f,0x46,0x41,0x58,0x31,0xb,0x30,0x9,0x6,0x3,0x55,0x4,0xb,0x13,0x2,
    0x49,0x54,0x31,0x21,0x30,0x1f,0x6,0x3,0x55,0x4,0xb,0x13,0x18,0x53,0x65,0x63,0x75,0x72,0x65,0x20,0x4c,0x69,0x6e,0x6b,0x20,0x53,0x53,0x4c,0x20,0x57,0x69,0x6c,0x64,0x63,0x61,0x72,0x64,0x31,0x14,0x30,0x12,0x6,0x3,0x55,0x4,0x3,0x14,0xb,0x2a,0x2e,
    0x6b,0x6f,0x66,0x61,0x78,0x2e,0x63,0x6f,0x6d,0x30,0x82,0x1,0x22,0x30,0xd,0x6,0x9,0x2a,0x86,0x48,0x86,0xf7,0xd,0x1,0x1,0x1,0x5,0x0,0x3,0x82,0x1,0xf,0x0,0x30,0x82,0x1,0xa,0x2,0x82,0x1,0x1,0x0,0xc2,0x4b,0x7e,0xb0,0xee,0x32,0x25,0x1b,
    0x48,0xa0,0x29,0x2e,0x45,0xd3,0x51,0x9d,0x2,0xc7,0x31,0x5e,0x4f,0xff,0x70,0x44,0x8e,0xaa,0x9b,0x61,0xb4,0xb9,0x50,0x71,0x8,0xfd,0x25,0xab,0x25,0x87,0x11,0x90,0x57,0x14,0xbc,0x7c,0xcf,0x14,0x3a,0x3e,0xc6,0xdc,0x99,0xae,0x92,0xad,0xe4,0xbe,0x2f,0xdb,
    0xd7,0x63,0x11,0xc7,0x3,0x93,0xf1,0xb1,0xfd,0x34,0x8a,0x13,0x66,0x92,0xa8,0x2d,0x5b,0x97,0x7a,0xbe,0xbe,0x63,0xb3,0xa5,0xe3,0xb7,0x44,0x85,0xca,0xba,0xc0,0x1b,0x12,0xb8,0x56,0x1e,0xd2,0xa0,0x4a,0xe,0x76,0xac,0x4,0xcc,0xfc,0x88,0x65,0x2f,0x17,0x15,
    0xd,0x16,0xd4,0xa1,0x72,0xdb,0x35,0xf8,0xde,0x8,0xfa,0x75,0x7f,0xad,0xdb,0x98,0x67,0x69,0xf2,0x4d,0xb2,0x2d,0x24,0xb9,0x93,0x7c,0xe3,0x66,0x53,0x46,0xe0,0x82,0x7d,0x81,0x79,0xb2,0xe6,0x2f,0x5b,0x22,0x0,0xbc,0x9f,0xe2,0x87,0x4b,0xb3,0x65,0xed,0x13,
    0x4b,0xd1,0x3f,0x4d,0x37,0x9f,0x6c,0xf3,0x6a,0xf9,0xdf,0xd1,0x19,0x25,0x4c,0x2d,0x6b,0x9b,0x39,0x46,0xe0,0x7a,0x87,0xc8,0x6,0xb0,0x85,0x76,0xd9,0x16,0x53,0x8b,0x7d,0x44,0x26,0x7,0xe8,0x2f,0x6e,0xb1,0x74,0x3f,0x86,0x29,0xc5,0x63,0x15,0x8,0x54,0xcb,
    0x4b,0xad,0x12,0x21,0x94,0x5a,0x9d,0x6a,0x68,0xa9,0xf4,0xe9,0x31,0xc6,0x3b,0xb8,0x6e,0xcb,0x2f,0x23,0x64,0xad,0x4a,0x9a,0xc6,0x7a,0xb0,0xa2,0x1b,0x2a,0xdd,0xd,0x24,0x58,0xa2,0x93,0x38,0x6e,0x18,0x5,0x3,0xfa,0x2d,0xe,0x2a,0x11,0xa2,0xff,0x2,0x3,
    0x1,0x0,0x1,0xa3,0x82,0x2,0x1,0x30,0x82,0x1,0xfd,0x30,0x1f,0x6,0x3,0x55,0x1d,0x23,0x4,0x18,0x30,0x16,0x80,0x14,0x3c,0x41,0xe2,0x8f,0x8,0x8,0xa9,0x4c,0x25,0x89,0x8d,0x6d,0xc5,0x38,0xd0,0xfc,0x85,0x8c,0x62,0x17,0x30,0x1d,0x6,0x3,0x55,0x1d,
    0xe,0x4,0x16,0x4,0x14,0xc6,0xcd,0xfc,0xce,0x66,0xcc,0x85,0x2c,0x42,0x1,0xae,0xda,0x69,0xd8,0x12,0x8f,0x65,0x2b,0x26,0x4c,0x30,0xe,0x6,0x3,0x55,0x1d,0xf,0x1,0x1,0xff,0x4,0x4,0x3,0x2,0x5,0xa0,0x30,0xc,0x6,0x3,0x55,0x1d,0x13,0x1,0x1,
    0xff,0x4,0x2,0x30,0x0,0x30,0x1d,0x6,0x3,0x55,0x1d,0x25,0x4,0x16,0x30,0x14,0x6,0x8,0x2b,0x6,0x1,0x5,0x5,0x7,0x3,0x1,0x6,0x8,0x2b,0x6,0x1,0x5,0x5,0x7,0x3,0x2,0x30,0x75,0x6,0x3,0x55,0x1d,0x20,0x4,0x6e,0x30,0x6c,0x30,0x60,0x6,
    0xc,0x2b,0x6,0x1,0x4,0x1,0x86,0xe,0x1,0x2,0x1,0x3,0x1,0x30,0x50,0x30,0x4e,0x6,0x8,0x2b,0x6,0x1,0x5,0x5,0x7,0x2,0x1,0x16,0x42,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x77,0x77,0x77,0x2e,0x6e,0x65,0x74,0x77,0x6f,0x72,0x6b,0x73,0x6f,0x6c,
    0x75,0x74,0x69,0x6f,0x6e,0x73,0x2e,0x63,0x6f,0x6d,0x2f,0x6c,0x65,0x67,0x61,0x6c,0x2f,0x53,0x53,0x4c,0x2d,0x6c,0x65,0x67,0x61,0x6c,0x2d,0x72,0x65,0x70,0x6f,0x73,0x69,0x74,0x6f,0x72,0x79,0x2d,0x63,0x70,0x73,0x2e,0x6a,0x73,0x70,0x30,0x8,0x6,0x6,0x67,
    0x81,0xc,0x1,0x2,0x2,0x30,0x7a,0x6,0x3,0x55,0x1d,0x1f,0x4,0x73,0x30,0x71,0x30,0x36,0xa0,0x34,0xa0,0x32,0x86,0x30,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x63,0x72,0x6c,0x2e,0x6e,0x65,0x74,0x73,0x6f,0x6c,0x73,0x73,0x6c,0x2e,0x63,0x6f,0x6d,0x2f,0x4e,
    0x65,0x74,0x77,0x6f,0x72,0x6b,0x53,0x6f,0x6c,0x75,0x74,0x69,0x6f,0x6e,0x73,0x5f,0x43,0x41,0x2e,0x63,0x72,0x6c,0x30,0x37,0xa0,0x35,0xa0,0x33,0x86,0x31,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x63,0x72,0x6c,0x32,0x2e,0x6e,0x65,0x74,0x73,0x6f,0x6c,0x73,0x73,
    0x6c,0x2e,0x63,0x6f,0x6d,0x2f,0x4e,0x65,0x74,0x77,0x6f,0x72,0x6b,0x53,0x6f,0x6c,0x75,0x74,0x69,0x6f,0x6e,0x73,0x5f,0x43,0x41,0x2e,0x63,0x72,0x6c,0x30,0x73,0x6,0x8,0x2b,0x6,0x1,0x5,0x5,0x7,0x1,0x1,0x4,0x67,0x30,0x65,0x30,0x3c,0x6,0x8,0x2b,
    0x6,0x1,0x5,0x5,0x7,0x30,0x2,0x86,0x30,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x77,0x77,0x77,0x2e,0x6e,0x65,0x74,0x73,0x6f,0x6c,0x73,0x73,0x6c,0x2e,0x63,0x6f,0x6d,0x2f,0x4e,0x65,0x74,0x77,0x6f,0x72,0x6b,0x53,0x6f,0x6c,0x75,0x74,0x69,0x6f,0x6e,0x73,
    0x5f,0x43,0x41,0x2e,0x63,0x72,0x74,0x30,0x25,0x6,0x8,0x2b,0x6,0x1,0x5,0x5,0x7,0x30,0x1,0x86,0x19,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x6f,0x63,0x73,0x70,0x2e,0x6e,0x65,0x74,0x73,0x6f,0x6c,0x73,0x73,0x6c,0x2e,0x63,0x6f,0x6d,0x30,0x16,0x6,0x3,
    0x55,0x1d,0x11,0x4,0xf,0x30,0xd,0x82,0xb,0x2a,0x2e,0x6b,0x6f,0x66,0x61,0x78,0x2e,0x63,0x6f,0x6d,0x30,0xd,0x6,0x9,0x2a,0x86,0x48,0x86,0xf7,0xd,0x1,0x1,0x5,0x5,0x0,0x3,0x82,0x1,0x1,0x0,0x69,0xdc,0xa1,0xb7,0x76,0x21,0x2b,0x91,0x40,0x38,
    0x12,0x58,0x38,0x3b,0xa4,0x5f,0xf3,0x40,0xff,0x6f,0xf8,0xaf,0x6d,0x17,0xf6,0x26,0x21,0x4d,0xdf,0x9a,0xb2,0x2d,0xd8,0x3c,0xb6,0x3b,0x27,0xb3,0x11,0xeb,0x3d,0x4a,0xa4,0xab,0xb1,0xed,0xc9,0x66,0xba,0xac,0x8b,0x14,0x32,0xeb,0x48,0x25,0xc1,0x1d,0x37,0xee,
    0xc2,0x21,0xef,0x71,0x36,0x19,0x4e,0x4a,0x31,0x3a,0x32,0xf8,0x75,0x90,0xe6,0x46,0xfe,0x1d,0x1c,0x82,0x6,0x9,0x3,0x3f,0x68,0xcc,0xda,0x5c,0x83,0x20,0x24,0x61,0x92,0x62,0x10,0x3c,0xe4,0xa7,0x29,0x67,0x45,0xef,0x2c,0x9a,0xb9,0x54,0x3e,0x7b,0xde,0x8d,
    0x9c,0x13,0xc9,0x8f,0x44,0x71,0x35,0xeb,0xef,0xae,0x78,0x15,0x27,0xf5,0x70,0xc9,0x26,0x22,0xf6,0xd6,0xc4,0x19,0x60,0x98,0xd,0x90,0xa8,0x12,0x43,0xe8,0x5d,0xd6,0xb6,0x54,0xe3,0x1,0x1b,0x4d,0x7b,0xa5,0x83,0x2,0x53,0xfe,0xa8,0x9,0xd5,0x2,0xbb,0x65,
    0xaf,0x2c,0xee,0xa1,0x7b,0xc1,0xef,0xf3,0xfe,0xd8,0xd9,0xe3,0x97,0xe9,0xd9,0x33,0xe9,0x26,0x54,0x68,0x7b,0x55,0xa4,0xb5,0x33,0x2c,0xc5,0x6b,0x91,0x6c,0x6f,0x7e,0x5e,0x66,0xa9,0x3,0x6d,0x11,0xf4,0xe6,0xbd,0x3d,0xb1,0xa4,0x1,0x15,0xa7,0x9b,0xef,0x33,
    0x59,0x71,0xd6,0x46,0x6d,0xd0,0x1a,0x55,0xa9,0x11,0xf0,0xd0,0xa6,0xb,0x72,0xfe,0x3f,0x8a,0xe,0xc5,0x5f,0x2b,0x4a,0x66,0x80,0x6e,0x3c,0x64,0x28,0xde,0x5d,0x46,0x7e,0x27,0xeb,0x11,0xf4,0xf3,0x16,0xde,0xcb,0xde,0xee,0x78,0xc4,0x94,
};

static const uint8_t MOBILEDEMO_DER_CERTIFICATE_NEW[] = {
    0x30,0x82,0x05,0x17,0x30,0x82,0x03,0xff,0xa0,0x03,0x02,0x01,0x02,0x02,0x10,0x0a,0x20,0x8c,0x39,0x50,0x42,0x44,0x92,0x3d,0x92,0xcd,0x98,0x54,0xc9,0x01,0x28,0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,0x0b,0x05,0x00,0x30,0x4d,0x31,0x0b,0x30,0x09,0x06,0x03,0x55,0x04,0x06,0x13,0x02,0x55,0x53,0x31,0x15,0x30,0x13,0x06,0x03,0x55,0x04,0x0a,0x13,0x0c,0x44,0x69,0x67,0x69,0x43,0x65,0x72,0x74,0x20,0x49,0x6e,0x63,0x31,0x27,0x30,0x25,0x06,0x03,0x55,0x04,0x03,0x13,0x1e,0x44,0x69,0x67,0x69,0x43,0x65,0x72,0x74,0x20,0x53,0x48,0x41,0x32,0x20,0x53,0x65,0x63,0x75,0x72,0x65,0x20,0x53,0x65,0x72,0x76,0x65,0x72,0x20,0x43,0x41,0x30,0x1e,0x17,0x0d,0x31,0x35,0x30,0x39,0x32,0x34,0x30,0x30,0x30,0x30,0x30,0x30,0x5a,0x17,0x0d,0x31,0x37,0x31,0x31,0x32,0x37,0x31,0x32,0x30,0x30,0x30,0x30,0x5a,0x30,0x6b,0x31,0x0b,0x30,0x09,0x06,0x03,0x55,0x04,0x06,0x13,0x02,0x55,0x53,0x31,0x13,0x30,0x11,0x06,0x03,0x55,0x04,0x08,0x13,0x0a,0x43,0x61,0x6c,0x69,0x66,0x6f,0x72,0x6e,0x69,0x61,0x31,0x0f,0x30,0x0d,0x06,0x03,0x55,0x04,0x07,0x13,0x06,0x49,0x72,0x76,0x69,0x6e,0x65,0x31,0x20,0x30,0x1e,0x06,0x03,0x55,0x04,0x0a,0x13,0x17,0x4b,0x6f,0x66,0x61,0x78,0x20,0x49,0x6e,0x74,0x65,0x72,0x6e,0x61,0x74,0x69,0x6f,0x6e,0x61,0x6c,0x20,0x49,0x6e,0x63,0x31,0x14,0x30,0x12,0x06,0x03,0x55,0x04,0x03,0x0c,0x0b,0x2a,0x2e,0x6b,0x6f,0x66,0x61,0x78,0x2e,0x63,0x6f,0x6d,0x30,0x82,0x01,0x22,0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,0x01,0x05,0x00,0x03,0x82,0x01,0x0f,0x00,0x30,0x82,0x01,0x0a,0x02,0x82,0x01,0x01,0x00,0xa8,0x8f,0x22,0x2d,0x7a,0xee,0xd6,0x71,0x9c,0xed,0xa8,0x03,0xd8,0x46,0xe6,0xc9,0xf7,0x2e,0x24,0xae,0x0d,0xd1,0x31,0xee,0xb5,0x21,0x03,0x0d,0x82,0x3b,0x23,0x06,0xef,0x07,0xf3,0x6e,0xe0,0xa9,0xd1,0x5f,0x33,0x43,0x4a,0xc1,0x0e,0x3c,0x1c,0xe2,0x41,0x05,0x9e,0xdb,0x1d,0x96,0x83,0xc5,0x5d,0xe7,0xcb,0x99,0x12,0xca,0x17,0xec,0x34,0xef,0x6b,0x67,0x16,0xff,0x75,0xfb,0xa2,0xdf,0x7d,0x5a,0x8a,0x6a,0xe6,0x62,0x83,0x7d,0xf3,0xe0,0x56,0x61,0x87,0xb5,0x50,0x96,0xa7,0xf0,0x09,0xd9,0x35,0xb4,0xc4,0xed,0x2e,0x4c,0x9d,0xd5,0x8f,0xf4,0x38,0xfb,0x91,0x23,0x10,0xb1,0x84,0xcb,0xd6,0x90,0x32,0xb5,0x04,0x76,0x71,0xd4,0x09,0xc0,0x52,0x47,0x94,0x1d,0xd3,0xd7,0xf6,0x70,0xfb,0x52,0x4d,0x30,0xc5,0x76,0xf8,0x45,0x95,0x20,0xe5,0x0f,0x45,0x84,0xc7,0x2b,0x47,0x32,0x35,0x2b,0x4b,0xf9,0xbf,0x18,0xe6,0x06,0x0d,0x4c,0x63,0xfb,0xcf,0xb7,0xce,0xcf,0x7c,0xeb,0x76,0xf5,0xef,0x89,0x86,0xc3,0xba,0x94,0xf6,0xaf,0xf5,0x85,0x5c,0xd6,0x1e,0x62,0x65,0xe4,0x34,0x7e,0x50,0x18,0x2b,0x38,0xeb,0x98,0xad,0xc2,0x7a,0x57,0x9c,0xb7,0x23,0x27,0x9f,0xc9,0xcf,0x8f,0x0e,0xe2,0x9b,0x1e,0xf2,0xd6,0xf4,0x4e,0x51,0x9c,0xc3,0xba,0x52,0x01,0xca,0xfc,0xda,0x9b,0x30,0xa5,0x64,0x92,0x71,0xe6,0x64,0xc1,0x13,0x07,0x68,0xa9,0x69,0xa5,0xbc,0x4c,0x5f,0x46,0xdd,0x08,0x07,0x8d,0x3e,0x26,0x17,0x36,0x77,0xcc,0x51,0x4a,0x8d,0x0b,0x70,0x8f,0x02,0x03,0x01,0x00,0x01,0xa3,0x82,0x01,0xd3,0x30,0x82,0x01,0xcf,0x30,0x1f,0x06,0x03,0x55,0x1d,0x23,0x04,0x18,0x30,0x16,0x80,0x14,0x0f,0x80,0x61,0x1c,0x82,0x31,0x61,0xd5,0x2f,0x28,0xe7,0x8d,0x46,0x38,0xb4,0x2c,0xe1,0xc6,0xd9,0xe2,0x30,0x1d,0x06,0x03,0x55,0x1d,0x0e,0x04,0x16,0x04,0x14,0x36,0x5e,0x78,0x60,0x7c,0xb3,0xbd,0x83,0x00,0xdc,0xd9,0xc0,0x43,0xc2,0x8c,0x42,0xea,0x8e,0xeb,0x4f,0x30,0x21,0x06,0x03,0x55,0x1d,0x11,0x04,0x1a,0x30,0x18,0x82,0x0b,0x2a,0x2e,0x6b,0x6f,0x66,0x61,0x78,0x2e,0x63,0x6f,0x6d,0x82,0x09,0x6b,0x6f,0x66,0x61,0x78,0x2e,0x63,0x6f,0x6d,0x30,0x0e,0x06,0x03,0x55,0x1d,0x0f,0x01,0x01,0xff,0x04,0x04,0x03,0x02,0x05,0xa0,0x30,0x1d,0x06,0x03,0x55,0x1d,0x25,0x04,0x16,0x30,0x14,0x06,0x08,0x2b,0x06,0x01,0x05,0x05,0x07,0x03,0x01,0x06,0x08,0x2b,0x06,0x01,0x05,0x05,0x07,0x03,0x02,0x30,0x6b,0x06,0x03,0x55,0x1d,0x1f,0x04,0x64,0x30,0x62,0x30,0x2f,0xa0,0x2d,0xa0,0x2b,0x86,0x29,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x63,0x72,0x6c,0x33,0x2e,0x64,0x69,0x67,0x69,0x63,0x65,0x72,0x74,0x2e,0x63,0x6f,0x6d,0x2f,0x73,0x73,0x63,0x61,0x2d,0x73,0x68,0x61,0x32,0x2d,0x67,0x34,0x2e,0x63,0x72,0x6c,0x30,0x2f,0xa0,0x2d,0xa0,0x2b,0x86,0x29,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x63,0x72,0x6c,0x34,0x2e,0x64,0x69,0x67,0x69,0x63,0x65,0x72,0x74,0x2e,0x63,0x6f,0x6d,0x2f,0x73,0x73,0x63,0x61,0x2d,0x73,0x68,0x61,0x32,0x2d,0x67,0x34,0x2e,0x63,0x72,0x6c,0x30,0x42,0x06,0x03,0x55,0x1d,0x20,0x04,0x3b,0x30,0x39,0x30,0x37,0x06,0x09,0x60,0x86,0x48,0x01,0x86,0xfd,0x6c,0x01,0x01,0x30,0x2a,0x30,0x28,0x06,0x08,0x2b,0x06,0x01,0x05,0x05,0x07,0x02,0x01,0x16,0x1c,0x68,0x74,0x74,0x70,0x73,0x3a,0x2f,0x2f,0x77,0x77,0x77,0x2e,0x64,0x69,0x67,0x69,0x63,0x65,0x72,0x74,0x2e,0x63,0x6f,0x6d,0x2f,0x43,0x50,0x53,0x30,0x7c,0x06,0x08,0x2b,0x06,0x01,0x05,0x05,0x07,0x01,0x01,0x04,0x70,0x30,0x6e,0x30,0x24,0x06,0x08,0x2b,0x06,0x01,0x05,0x05,0x07,0x30,0x01,0x86,0x18,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x6f,0x63,0x73,0x70,0x2e,0x64,0x69,0x67,0x69,0x63,0x65,0x72,0x74,0x2e,0x63,0x6f,0x6d,0x30,0x46,0x06,0x08,0x2b,0x06,0x01,0x05,0x05,0x07,0x30,0x02,0x86,0x3a,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x63,0x61,0x63,0x65,0x72,0x74,0x73,0x2e,0x64,0x69,0x67,0x69,0x63,0x65,0x72,0x74,0x2e,0x63,0x6f,0x6d,0x2f,0x44,0x69,0x67,0x69,0x43,0x65,0x72,0x74,0x53,0x48,0x41,0x32,0x53,0x65,0x63,0x75,0x72,0x65,0x53,0x65,0x72,0x76,0x65,0x72,0x43,0x41,0x2e,0x63,0x72,0x74,0x30,0x0c,0x06,0x03,0x55,0x1d,0x13,0x01,0x01,0xff,0x04,0x02,0x30,0x00,0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,0x0b,0x05,0x00,0x03,0x82,0x01,0x01,0x00,0x19,0xce,0x83,0xb6,0x58,0xf4,0x1a,0x55,0xf4,0x63,0x31,0x10,0x7c,0x4d,0x5c,0x7c,0x94,0x68,0x87,0x4c,0x80,0xd2,0xea,0xe4,0xdf,0x55,0x54,0x38,0x7d,0xb6,0x3f,0xfe,0xf9,0xbf,0x8e,0xd5,0x06,0x10,0xdb,0x0a,0x8a,0x20,0xcd,0xdb,0x8e,0xb7,0xf7,0x1b,0x19,0x22,0xe2,0x10,0xac,0x51,0x1e,0x19,0x08,0xba,0x17,0x91,0x99,0x92,0x29,0x05,0x32,0x88,0x25,0x32,0x6b,0xc7,0x10,0xb4,0x06,0xe6,0x6f,0x7c,0x82,0x89,0x49,0xe8,0xc4,0x81,0x5d,0x38,0x4d,0x2d,0xfa,0x21,0xf4,0x93,0x2c,0x1f,0xf5,0xa6,0x79,0x7d,0x19,0x9a,0xb3,0xa6,0x59,0xcb,0xd9,0x45,0x3d,0x18,0x53,0x87,0x88,0xf5,0x5e,0x71,0xf5,0xf6,0xdc,0xc3,0x51,0x02,0xd7,0xf6,0x5d,0x93,0xb9,0xf9,0x43,0x6d,0xc5,0xd9,0x70,0x0f,0x1c,0x00,0x5c,0x13,0x7d,0x4f,0x0c,0xed,0x10,0x3d,0x95,0x02,0x1a,0x40,0xd2,0x8e,0x97,0xbd,0xa9,0x5b,0x90,0x43,0x3e,0x1a,0x9e,0xf2,0xd3,0x50,0x76,0xb5,0x38,0x9b,0x1a,0xff,0x9e,0x6b,0xf2,0x30,0x7c,0x33,0xea,0x87,0x78,0x87,0xf6,0xa4,0xac,0x9c,0x44,0x4e,0xb6,0xf6,0xb8,0x82,0x1b,0x2c,0x87,0x34,0x5d,0x52,0xf1,0xc7,0x33,0xd5,0x96,0xf1,0xf3,0xe4,0x9b,0x45,0xbf,0x22,0x32,0x23,0x1b,0xbc,0xe9,0x08,0x45,0xea,0xbb,0x64,0x25,0xb9,0x7b,0x6e,0xd4,0x35,0xe4,0x78,0xd5,0xc8,0x4c,0x30,0xc7,0xb0,0x0e,0xc9,0xaf,0x76,0xed,0xe0,0x89,0x2a,0x31,0xc3,0x3a,0x0d,0xc8,0xac,0x22,0x43,0x2b,0xcb,0x94,0x0c,0xce,0x1b,0x62,0x9e,0xb4,0xcc,0xd7,0x77,0x5e,0x85
};


@interface CertificatePinningManager ()

@end

@implementation CertificatePinningManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static CertificatePinningManager* instance = nil;
    dispatch_once(&once,^
    {
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)handleConnection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust] &&
        [self isKnownHostForPinning:challenge])
    {
        NSURLCredential* credential = [self credentialsForAuthenticationChallenge:challenge];
        if (credential)
        {
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }
        else
        {
            [challenge.sender cancelAuthenticationChallenge:challenge];
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleURLSession:(NSURLSession*)session
     didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge
       completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler
{
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust] &&
        [self isKnownHostForPinning:challenge])
    {
        NSURLCredential* credential = [self credentialsForAuthenticationChallenge:challenge];
        if (credential)
        {
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else
        {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        return YES;
    }
    return NO;
}

- (NSURLCredential*)credentialsForAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
    NSLog(@"credentialsForAuthenticationChallenge: [%@:%ld, %@]", challenge.protectionSpace.host,
          challenge.protectionSpace.port,
          challenge.protectionSpace.protocol);
    
    SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
    if (nil == serverTrust)
    {
        NSLog(@"Error: Get server trust is failed");
        return nil;
    }

    NSData* cert1 = nil;
    {
        OSStatus status = SecTrustEvaluate(serverTrust, NULL);
        if (!(errSecSuccess == status))
        {
            NSLog(@"Error: SecTrustEvaluate failed: %d", status);
            return nil;
        }

        SecCertificateRef serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
        if (nil == serverCertificate)
        {
            NSLog(@"Error: SecTrustGetCertificateAtIndex failed");
            return nil;
        }

        cert1 = (__bridge_transfer NSData*)SecCertificateCopyData(serverCertificate);
        if (nil == cert1)
        {
            NSLog(@"Error: SecCertificateCopyData failed");
            return nil;
        }
    }
    
    NSData* cert2 = nil;
    NSData* certificate_new = nil;
    if ([challenge.protectionSpace.host isEqualToString:@"mobiledemo.kofax.com"] ||
        [challenge.protectionSpace.host isEqualToString:@"mobilekta-beta.kofax.com"])
    {
        cert2 = [NSData dataWithBytes:MOBILEDEMO_DER_CERTIFICATE length:sizeof(MOBILEDEMO_DER_CERTIFICATE)];
        
        if (nil == cert2)
        {
            NSLog(@"Error: certificate old is empty");
            return nil;
        }
        
        if (![cert1 isEqualToData:cert2])
        {
            certificate_new = [NSData dataWithBytes:MOBILEDEMO_DER_CERTIFICATE_NEW length:sizeof(MOBILEDEMO_DER_CERTIFICATE_NEW)];
            
            if(certificate_new == nil)
            {
                NSLog(@"Error: certificate new is empty");
                return nil;
            }
            
            if(![cert1 isEqualToData:certificate_new])
            {
                NSLog(@"Error: certificates are not equal");
                return nil;

            }
        }
    }
    

    return [NSURLCredential credentialForTrust:serverTrust];
}

- (BOOL)isKnownHostForPinning:(NSURLAuthenticationChallenge*)challenge
{
    return ([challenge.protectionSpace.host isEqualToString:@"mobiledemo.kofax.com"] ||
            [challenge.protectionSpace.host isEqualToString:@"mobilekta-beta.kofax.com"]);
}

@end