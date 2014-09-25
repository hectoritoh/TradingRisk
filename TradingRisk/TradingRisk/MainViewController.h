//
//  MainViewController.h
//  TradingRisk
//
//  Created by Hector on 9/2/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate>

@property(retain,nonatomic) MBProgressHUD *hud;
@property(retain,nonatomic) UITableView *tableview;
@property(retain,nonatomic) UIRefreshControl *refreshControl;



@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *verInfo;



@end
