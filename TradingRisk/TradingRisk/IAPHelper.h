//
//  IAPHelper.h
//  TradingRisk
//
//  Created by Hector on 9/1/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;


typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);


@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;


/// compra de productos
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

@end
