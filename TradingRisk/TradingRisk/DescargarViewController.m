//
//  DescargarViewController.m
//  TradingRisk
//
//  Created by Hector on 9/16/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import "DescargarViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface DescargarViewController ()

@end

@implementation DescargarViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* txt_titulo = (UILabel*) [self.view viewWithTag:10];
    [txt_titulo setText:self.titulo];
    
    self.progreso = (UILabel*) [self.view viewWithTag:20];

    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Descargando revista";
    self.hud.mode = MBProgressHUDModeDeterminate;
    self.hud.dimBackground = YES;
    
    
    
    
    

    NSURL *URL = [NSURL URLWithString: self.ruta_descarga   ];
    
    
    
    
    NSString* theFileName = [[ self.ruta_descarga   lastPathComponent] stringByDeletingPathExtension];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent: theFileName  ];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    
    
    
    
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent: theFileName  ];
//    NSLog(@"archivo almacenado en la ruta %@" , filePath);
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        float progreso  = (float)totalBytesRead / totalBytesExpectedToRead;
        NSLog(@"%f" , progreso);
        self.hud.progress = progreso;
        float porcentaje = progreso * 100 ;
        
        [self.progreso setText: [NSString stringWithFormat:@"%.2f %% ", porcentaje ]  ];
        
        //            progress.progress = (float)totalBytesRead / totalBytesExpectedToRead;
        
        
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"downloadComplete!");
        [self.hud hide:YES];
        NSUserDefaults* defautls = [NSUserDefaults standardUserDefaults ];
        [defautls setObject:@"si" forKey:@"recargar"];
        [defautls synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [operation start];
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end