#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "bill" asset catalog image resource.
static NSString * const ACImageNameBill AC_SWIFT_PRIVATE = @"bill";

/// The "checked" asset catalog image resource.
static NSString * const ACImageNameChecked AC_SWIFT_PRIVATE = @"checked";

/// The "customer" asset catalog image resource.
static NSString * const ACImageNameCustomer AC_SWIFT_PRIVATE = @"customer";

/// The "exit" asset catalog image resource.
static NSString * const ACImageNameExit AC_SWIFT_PRIVATE = @"exit";

/// The "login" asset catalog image resource.
static NSString * const ACImageNameLogin AC_SWIFT_PRIVATE = @"login";

/// The "logo" asset catalog image resource.
static NSString * const ACImageNameLogo AC_SWIFT_PRIVATE = @"logo";

/// The "orderList" asset catalog image resource.
static NSString * const ACImageNameOrderList AC_SWIFT_PRIVATE = @"orderList";

/// The "passw" asset catalog image resource.
static NSString * const ACImageNamePassw AC_SWIFT_PRIVATE = @"passw";

/// The "unchecked" asset catalog image resource.
static NSString * const ACImageNameUnchecked AC_SWIFT_PRIVATE = @"unchecked";

/// The "user" asset catalog image resource.
static NSString * const ACImageNameUser AC_SWIFT_PRIVATE = @"user";

#undef AC_SWIFT_PRIVATE
