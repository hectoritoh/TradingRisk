//
//  RevistaEntity.h
//  TradingRisk
//
//  Created by Hector on 10/2/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RevistaEntity : NSObject{

    int        _codigo;
    NSString * _codigo_android ;
    NSString * _codigo_iphone;
    NSString * _descripcion;
    NSString * _gratis;
    NSString * _id_revista;
    NSString * _nombre;
    NSString * _url_descarga;
    NSString * _url_portada;
    
    
}

@property (nonatomic, assign) int codigo;
@property (nonatomic, copy) NSString *codigo_android ;
@property (nonatomic, copy) NSString *codigo_iphone;
@property (nonatomic, copy) NSString *descripcion;
@property (nonatomic, copy) NSString *gratis;
@property (nonatomic, copy) NSString *id_revista;
@property (nonatomic, copy) NSString *nombre;
@property (nonatomic, copy) NSString *url_descarga;
@property (nonatomic, copy) NSString *url_portada;





@end
