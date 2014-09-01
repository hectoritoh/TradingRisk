//
//  IAPHelper.h
//  TradingRisk
//
//  Created by Hector on 9/1/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);


@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
