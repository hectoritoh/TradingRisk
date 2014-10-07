//
//  RevistaDB.h
//  TradingRisk
//
//  Created by Hector on 10/2/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface RevistaDB : NSObject{

        sqlite3 *_database;
    NSString* databasePath; 
}

+ (RevistaDB*)database;
- (NSArray *)failedBankInfos;


- (NSArray *)getRevistas ; 
- (void) grabarRevista:(NSDictionary*) revista; 

- (NSString *)getVersion ; 
- (void )actualizarVersion:(NSString*) version ; 
@end


