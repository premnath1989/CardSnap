//=========================================================================
//
//
// Copyright (c) 2012-2014 Kofax. Use of this code is with permission pursuant to Kofax license terms.
//
//
//
// Kofax VRS Mobile SDK
//
// This file defines the error codes returned from the Kofax VRS Mobile SDK
// library, the structures used by the API functions, and the API functions
// used to process images with the library.
//=========================================================================

#ifndef kfxVRSMbl_h
#define kfxVRSMbl_h

//=========================================================================
// CONSTANTS, ETC
//=========================================================================

typedef int Bool;

//-------------------------------------------------------------------------
// max length of license string
#define LEN_LICENSE_STR                          128

//-------------------------------------------------------------------------
// Error codes for those API functions that return an error
#define EVRS_IP_SUCCESS                            0
#define EVRS_IP_MEMORY_ALLOC_ERROR                -1
#define EVRS_IP_FILE_OPEN_ERROR                   -2
#define EVRS_IP_BAD_DPI_ERROR                     -3
#define EVRS_IP_BAD_WIDTH_HEIGHT_ERROR            -4
#define EVRS_IP_BAD_LINEWIDTH_ERROR               -5
#define EVRS_IP_BAD_CHANNEL_ERROR                 -6
#define EVRS_IPL_ERROR                            -7
#define EVRS_IP_FILE_READ_ERROR                   -8
#define EVRS_IP_IMAGE_PARAM_ERROR                 -9
#define EVRS_IP_IMAGE_PROCESSING_ERROR           -10
#define EVRS_IP_IMAGE_WRITE_ERROR                -11
#define EVRS_UNKNOWN_FILETYPE                    -12
#define EVRS_IMAGE_DOES_NOT_EXIST                -13
#define EVRS_BAD_FILE_FORMAT_INTERNALS           -14
#define EVRS_BAD_FILE_TO_APPEND_TO               -15
#define EVRS_CANNOT_APPEND_TO_FILETYPE           -16
#define EVRS_BAD_PDF                             -17
#define EVRS_ENCRYPTED_APPEND_ERROR              -18
#define EVRS_PDF_TOO_LARGE_TO_APPEND             -19
#define EVRS_BAD_SPEED_ACCURACY_ERROR            -20
#define EVRS_READING_USER_NETWORK_ERROR          -21
#define EVRS_FILE_METADATA_ERROR                 -22
#define EVRS_INCONSISTENT_BW_TRANSITIONS_ERROR   -66
#define EVRS_IP_BAD_EXTERNAL_PAGE                -88
#define EVRS_IP_MMX_PROCESSING_ERROR             -99
#define EVRS_IP_LICENSING_FAILURE              -1000
#define EVRS_IP_LICENSE_EXPIRATION_ERROR       -1001

//=========================================================================
// VRS Operations String Tokens
//=========================================================================

#define DEFAULT_OUTPUT_QUALITY   80

#define DO_PREVIEW			 "_DoPreview_"
#define DO_HEALTH_ANALYSIS		 "_DoHealthAnalysis_"
#define DO_ILLUMINATION_CORRECTION       "_DoIlluminationCorrection_"
#define DO_RECTANGULARIZATION            "_DoRectangularization_"
#define DO_RECTANGULARIZATION_DETECTION  "_DoRectangularizationDetection_"
#define DO_BLUR_AND_ILLUMINATION_CHECK   "_DoBlurAndIlluminationCheck_"
#define DO_HOLE_FILL                     "_DoHoleFill_"
#define DO_BLANK_PAGE_DETECTION          "_DoBlankPageDetection_"
#define DO_COLOR_DETECTION               "_DoColorDetection_"
#define DO_CROP_CORRECTION               "_DoCropCorrection_"
#define DO_SKEW_CORRECTION_PAGE          "_DoSkewCorrectionPage_"
#define DO_SKEW_CORRECTION_ALT           "_DoSkewCorrectionAlt_"
#define DO_BINARIZATION                  "_DoBinarization_"
#define DO_GRAY_OUTPUT                   "_DoGrayOutput_"
#define DO_SCANNER_BKG_FILL              "_DoScannerBkgFill_"
#define DO_CONTOUR_CLEANING              "_DoContourCleaning_"
#define DO_90_DEGREE_ROTATION            "_Do90DegreeRotation_"
#define DO_BARCODE_DETECTION             "_DoBarcodeDetection_"
#define DO_DESPECK                       "_DoDespeck_" // E.g., _DoDespeck_4 to remove 4x4 pixel and smaller specks
#define DO_EDGE_CLEANUP                  "_DoEdgeCleanup_"
#define DO_BACKGROUND_SMOOTHING          "_DoBackgroundSmoothing_"
#define DO_MERGE_FRONT_BACK              "_DoMergeFrontBack_"
#define DO_SCALE_IMAGE_TO_DPI            "_DoScaleImageToDPI_"
#define DO_SHARPEN                       "_DoSharpen_"
#define DO_FIND_TEXT_LINES               "_DoFindTextLines_"
#define DO_ENHANCED_BINARIZATION         "_DoEnhancedBinarization_"

#define DO_ROTATE_NONE                   "_Do90DegreeRotation_0"
#define DO_ROTATE_90                     "_Do90DegreeRotation_3" // 90 degrees clockwise
#define DO_ROTATE_180                    "_Do90DegreeRotation_2" // 180 degrees
#define DO_ROTATE_270                    "_Do90DegreeRotation_1" // 270 degrees clockwise
#define DO_ROTATE_AUTO                   "_Do90DegreeRotation_4" // Auto Rotate

#define LOAD_SETTINGS                    "_LoadSetting_"

#define DO_NO_PAGE_DETECTION             "_DoNoPageDetection_"

#define EXTERNAL_CORNERS_FRONT           "_ExternalCornersFront_"
#define EXTERNAL_CORNERS_BACK            "_ExternalCornersBack_"

#define EXTERNAL_TETRAGON_SIDES_FRONT    "_ExternalTetragonSidesFront_"
#define EXTERNAL_TETRAGON_SIDES_BACK     "_ExternalTetragonSidesBack_"

#define LOAD_FRONT_IMAGE                 "_LoadFrontImage_"
#define LOAD_BACK_IMAGE                  "_LoadBackImage_"
#define SAVE_FRONT_IMAGE                 "_SaveFrontImage_"
#define SAVE_BACK_IMAGE                  "_SaveBackImage_"

#define DEVICE_MAKE                      "_DeviceMake_"
#define DEVICE_MODEL                     "_DeviceModel_"

#define DEVICE_TYPE                      "_DeviceType_"

#define USE_FLASH                        "_Flash_"

#define FRONT_SIDE_BLANK                 "_FrontSideBlank_"
#define BACK_SIDE_BLANK                  "_BackSideBlank_"

#define FRONT_BARCODE_START              "_FrontBarcodesStart_"
#define FRONT_BARCODE_END                "_FrontBarcodesEnd_"

#define BACK_BARCODE_START               "_BackBarcodesStart_"
#define BACK_BARCODE_END                 "_BackBarcodesEnd_"

#define AUTO_ORIENTATION_DONE            "_AutoOrientationDone_"

#define PAGE_FRAME_MARGIN                  8

#endif
