//
//  TradingRiskIAPHelper.m
//  TradingRisk
//
//  Created by Hector on 9/1/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import "TradingRiskIAPHelper.h"

@implementation TradingRiskIAPHelper



+ (TradingRiskIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TradingRiskIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"tradingrisk01",
                                      @"desa.celmedia.TradingRisk.tradingrisk02",
                                      @"mi.revista.3" ,
                                      @"mi.revista.4" ,                                      
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


@end
