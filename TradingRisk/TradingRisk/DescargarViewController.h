//
//  DescargarViewController.h
//  TradingRisk
//
//  Created by Hector on 9/16/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface DescargarViewController : UIViewController

@property(retain,nonatomic) MBProgressHUD *hud;

@property(retain,nonatomic) UIButton * cancelar;
@property(retain,nonatomic) UILabel  * progreso;


@property(retain,nonatomic) NSString * ruta_descarga;
@property(retain,nonatomic) NSString * titulo;


@end
