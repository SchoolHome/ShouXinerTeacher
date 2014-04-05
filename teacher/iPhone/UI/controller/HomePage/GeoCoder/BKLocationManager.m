//
// Created by Bruno Wernimont on 2012
// Copyright 2012 BaseKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "BKLocationManager.h"

#import "BKMacrosDefinitions.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BKLocationManager ()

+ (id)manager;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BKLocationManager

@synthesize locationManager = _locationManager;


#if !BK_HAS_ARC
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    self.locationManager = nil;
    Block_release(_didUpdateLocationBlock);
    Block_release(_didFailBlock);
    
    [super dealloc];
}
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)sharedManager {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = BK_RETAIN([self manager]);
    });
    
    return _sharedObject;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)manager {
    return BK_AUTORELEASE([[self alloc ] init]);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.delegate = self;
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startUpdatingLocationWithAccuracy:(CLLocationAccuracy)accurary {
    self.locationManager.desiredAccuracy = accurary;
    [self.locationManager startUpdatingLocation];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startUpdatingLocation {
    [self startUpdatingLocationWithAccuracy:self.desiredAccuracy];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDidUpdateLocationBlock:(BKLocationManagerDidUpdateLocation)block {
    if (nil != block) {
#if !BK_HAS_ARC
        Block_release(_didUpdateLocationBlock);
#endif
        _didUpdateLocationBlock = [block copy];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDidFailBlock:(BKLocationManagerDidFail)block {
    if (nil != block) {
#if !BK_HAS_ARC
        Block_release(_didFailBlock);
#endif
        _didFailBlock = [block copy];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters and setters


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    self.locationManager.desiredAccuracy = desiredAccuracy;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CLLocationAccuracy)desiredAccuracy {
    return self.locationManager.desiredAccuracy;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocationManagerDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    if (nil != _didUpdateLocationBlock) {
        _didUpdateLocationBlock(manager, newLocation, oldLocation);
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
    
    if (nil != _didFailBlock) {
        _didFailBlock(manager, error);
    }
    
	[self.locationManager stopUpdatingLocation];
}


@end
