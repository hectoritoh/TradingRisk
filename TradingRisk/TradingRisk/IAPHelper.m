//
//  IAPHelper.m
//  TradingRisk
//
//  Created by Hector on 9/1/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

// 2
@interface IAPHelper () <SKProductsRequestDelegate>
@end

@implementation IAPHelper {
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
    }
    return self;
}


- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}





#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    
    
    NSArray *items = response.products;
    
    for(SKProduct *item in items)
    {
        
        NSLog(@"Product title: %@" , item.localizedTitle);
        NSLog(@"Product description: %@" , item.localizedDescription);
        NSLog(@"Product price: %@" , item.price);
        NSLog(@"Product id: %@" , item.productIdentifier);
        
        
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {


        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }

    
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}



@end