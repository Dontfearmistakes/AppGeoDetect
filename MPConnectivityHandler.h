//
//  MPConnectivityHandler.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 25/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MPConnectivityHandler : NSObject
-(void)setUpPeerSessionAndStartAdvertising;
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
@end
