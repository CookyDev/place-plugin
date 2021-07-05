#import "PlacePlugin.h"
#import<place_plugin/place_plugin-Swift.h>

@implementation PlacePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPlacePlugin registerWithRegistrar:registrar];
}
@end
