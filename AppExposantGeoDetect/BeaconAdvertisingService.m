//
//  BeaconAdvertisingService.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 19/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "BeaconAdvertisingService.h"

@import CoreBluetooth;

NSString * const kBeaconIdentifier = @"com.razeware.waitlist";

@interface BeaconAdvertisingService () <CBPeripheralManagerDelegate>

@property (nonatomic, readwrite, getter = isAdvertising) BOOL advertising;
@property (assign) BOOL needsStartAdvertising;
@property (strong) NSUUID *currentUUID;
@property (assign) CLBeaconMajorValue currentMajor;
@property (assign) CLBeaconMajorValue currentMinor;

@end

@implementation BeaconAdvertisingService {
    CBPeripheralManager *_peripheralManager;
}

+ (BeaconAdvertisingService *)sharedInstance {
    static BeaconAdvertisingService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    else
    {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        self.needsStartAdvertising = NO;
    }
    
    return self;
}



- (void)startAdvertisingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor
{
    NSError *bluetoothStateError = nil;
    self.currentUUID =uuid;
    self.currentMajor = major;
    self.currentMinor = minor;
    
    //Si le bluetooth n'est pas encore allumé
    if (![self bluetoothStateValid:&bluetoothStateError]) {
        //[[[UIAlertView alloc] initWithTitle:@"Bluetooth Issue" message:bluetoothStateError.userInfo[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        //alors on a toujours besoin d'appeler startAdvertising et c'est pas la peine de le faire tout de suite (->return)
        self.needsStartAdvertising = YES;
        return;
    }
    
    CLBeaconRegion *region;
    if (uuid && major && minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:kBeaconIdentifier];
    } else if (uuid && major) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major identifier:kBeaconIdentifier];
    } else if (uuid) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kBeaconIdentifier];
    } else {
        [NSException raise:@"You must at least provide a UUID to start advertising" format:nil];
    }
    
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:nil];
    [_peripheralManager startAdvertising:peripheralData];
}



- (void)stopAdvertising
{
    [_peripheralManager stopAdvertising];
    self.advertising = NO;
}

//Le Bluetooth a changé d'Etat
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSError *bluetoothStateError = nil;
    
    //Si le peripheral manager (le bluetooth) est bien activé et qu'on est pas déjà rentré dans cette boucle
    if ([self bluetoothStateValid:&bluetoothStateError] && self.needsStartAdvertising)
    {
        //Alors on advertise et on a plus besoin de le faire
        [self startAdvertisingUUID:self.currentUUID major:self.currentMajor minor:self.currentMinor];
        self.needsStartAdvertising  = NO;
    }
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Cannot Advertise Beacon" message:@"There was an issue starting the advertisement of your beacon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Start Advertising Error: %@", error);
        } else {
            NSLog(@"Advertising!");
            self.advertising = YES;
        }
    });
}



- (BOOL)bluetoothStateValid:(NSError **)error {
    BOOL bluetoothStateValid = YES;
    switch (_peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOff:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStatePoweredOff
                                         userInfo:@{@"message": @"You must turn Bluetooth on in order to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateResetting:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateResetting
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnauthorized:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnauthorized
                                         userInfo:@{@"message": @"This application is not authorized to use Bluetooth, verify your settings or check with your device's administrator"}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnknown:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnknown
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnsupported:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnsupported
                                         userInfo:@{@"message": @"Your device does not support Bluetooth. You will not be able to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStatePoweredOn:
            bluetoothStateValid = YES;
            break;
    }
    
    return bluetoothStateValid;
}

@end

