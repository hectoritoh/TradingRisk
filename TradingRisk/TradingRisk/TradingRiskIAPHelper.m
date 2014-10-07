//
//  TradingRiskIAPHelper.m
//  TradingRisk
//
//  Created by Hector on 9/1/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import "TradingRiskIAPHelper.h"
#import "RevistaDB.h"
#import "RevistaEntity.h"

@implementation TradingRiskIAPHelper



+ (TradingRiskIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TradingRiskIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        
        
        
        

       NSArray* revista =  [[RevistaDB  database ] getRevistas  ];

        NSMutableArray* productos_id = [[ NSMutableArray alloc ] init ] ;
        
        for (RevistaEntity* object in revista ) {
            [  productos_id addObject:   [  object codigo_iphone ] ];
            NSLog(@"desde base registro encontrado: %@" ,   [  object codigo_iphone ] );
        }
        
        NSSet *productIdentifiers = [NSSet setWithArray: productos_id ];

//        [productIdentifiers setByAddingObjectsFromArray:productos_id];
        

//            NSSet * productIdentifiers = [NSSet setWithObjects:
//                                          @"tradingrisk01",
//                                          @"desa.celmedia.TradingRisk.tradingrisk02",
//                                          @"mi.revista.3" ,
//                                          @"mi.revista.4" ,
//                                          nil];
        
            
            sharedInstance = [[self alloc] initWithProductIdentifiers: productIdentifiers  ];
            
        
        
    });
    return sharedInstance;
}


@end
