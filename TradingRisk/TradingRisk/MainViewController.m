//
//  MainViewController.m
//  TradingRisk
//
//  Created by Hector on 9/2/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//
#import "MainViewController.h"
#import "TradingRiskIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ReaderBookDelegate.h"
#import "ReaderViewController.h"

#import "AFNetworking/AFNetworking.h"
#import "PagedImageScrollView.h"

@interface MainViewController () <ReaderViewControllerDelegate>

@end

@implementation MainViewController


NSArray *_products;
NSMutableArray *_revistas;

ReaderViewController *readerViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    PagedImageScrollView *pageScrollView = [[PagedImageScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    [pageScrollView setScrollViewContents:@[[UIImage imageNamed:@"banner.png"], [UIImage imageNamed:@"banner2.jpg"], [UIImage imageNamed:@"banner3.jpg"], [UIImage imageNamed:@"banner4.jpg"]]];
    //easily setting pagecontrol pos, see PageControlPosition defination in PagedImageScrollView.h
    pageScrollView.pageControlPos = PageControlPositionCenterBottom;
    [self.view addSubview:pageScrollView];
    

     

    
    _tableview = (UITableView*) [ self.view viewWithTag:10 ];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    [self.navigationController setTitle:@"Trading Risk"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [_tableview addSubview:self.refreshControl];
    
    [self reload];
    [self.refreshControl beginRefreshing];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 4
- (void)reload {
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Actualizando catalogo";
    self.hud.dimBackground = YES;
    
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://104.131.8.100/tradingRisk/servicio.php"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             
             _revistas  = [[NSMutableArray alloc] init];
             
             NSLog(@"response type %@ " , [responseObject class] );
             
             for (id object in responseObject ) {
                 NSDictionary *currentObject = (NSDictionary*)object;
                 
                 [_revistas addObject:currentObject];
                
             }
             
             
             NSLog(@"Encontrados %lu registros en el servidor " , (unsigned long)[_revistas count ]  );
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
    
    
    
    _products = nil;
    [self.tableview reloadData];
    [[TradingRiskIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [_tableview reloadData];
            [self.hud hide:YES ];
        }else{
            
            
            [self.hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Error de conexion"
                                                           message: @"Problemas al cargar items"
                                                          delegate: self
                                                 cancelButtonTitle:@"Reintentar"
                                                 otherButtonTitles:nil,nil];
            
            
            [alert show];
            
            
        }
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return _products.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return 90.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    UIView* view = (UIView *) [cell viewWithTag:123 ];
    

    [view.layer setCornerRadius:5.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:0.5f];
    
    
    
    
    
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    
    UILabel* titulo = (UILabel *) [cell viewWithTag:10 ];
    titulo.text = product.localizedTitle;
    
    
    UILabel* precio = (UILabel*) [  cell viewWithTag:20];
    precio.text = [ NSString stringWithFormat:@"$%@" , product.price];
    
    
    
    UIButton* accion = (UIButton*) [ cell viewWithTag:30 ];
    
    
    if ([[TradingRiskIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        
        
        
        
        NSDictionary* revista = [ _revistas objectAtIndex: [ indexPath row  ] ];
        
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* archivoDescargar = [documentsPath stringByAppendingPathComponent: [revista  objectForKey:@"nombre_archivo" ]  ];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:archivoDescargar];
        
        
        
        if (fileExists) {

            UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buyButton.frame = CGRectMake(0, 0, 72, 37);
            [buyButton setTitle:@"Leer" forState:UIControlStateNormal];
            buyButton.tag = indexPath.row;
            [buyButton addTarget:self action:@selector(descargar:) forControlEvents:UIControlEventTouchUpInside];

            [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
            [accion addTarget:self action:@selector(descargar:) forControlEvents:UIControlEventTouchUpInside];
            
            
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            cell.accessoryView = buyButton;

            
        }else{
        
            UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buyButton.frame = CGRectMake(0, 0, 72, 37);
            [buyButton setTitle:@"Descargar" forState:UIControlStateNormal];
            buyButton.tag = indexPath.row;
            
            [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
//            [accion addTarget:self action:@selector(mostrarDetalle:) forControlEvents:UIControlEventTouchUpInside];
            [accion addTarget:self action:@selector(descargar:) forControlEvents:UIControlEventTouchUpInside];

//            cell.accessoryType = UITableViewCellAccessoryNone;
//            cell.accessoryView = buyButton;

        }
        
        
        
        
        
    } else {
//        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        buyButton.frame = CGRectMake(0, 0, 72, 37);
//        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
//        buyButton.tag = indexPath.row;
//        
        

        [accion addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.accessoryView = buyButton;
//        
    }
    
    return cell;
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell.contentView.layer setCornerRadius:7.0f];
    [cell.contentView.layer setMasksToBounds:YES];
}



- (void)buyButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;

    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview.superview;
    UITableView *tableView = (UITableView *)cell.superview.superview;
    NSIndexPath *clickedButtonIndexPath = [tableView indexPathForCell:cell];
    
    
    NSLog(@"  indice %ld" , (long)[clickedButtonIndexPath row ] );
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[ clickedButtonIndexPath.row  ];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[TradingRiskIAPHelper sharedInstance] buyProduct:product];
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [_tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}




-(void) cargarPdf: (NSString*) nombre_archivo {
    
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
	NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:nombre_archivo password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed
	{
		readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
		[self presentViewController:readerViewController animated:YES completion:NULL];
        
	}
    
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    NSLog(@"Cerrando");
	[self dismissViewControllerAnimated:YES completion:NULL];
    
}




-(void)descargar:(id)sender {
    
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonIndexPath = [self.tableview indexPathForCell:clickedCell];

    NSLog(@"Evento de descarga lanzado indice %ld" , (long)[clickedButtonIndexPath row] );
    
    NSDictionary* revista = [ _revistas objectAtIndex: [ clickedButtonIndexPath row  ] ];
    NSURL *URL = [NSURL URLWithString: [revista  objectForKey:@"url_descarga" ]   ];
    
    
    
    NSString* documentsPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* archivoDescargar = [documentsPath stringByAppendingPathComponent: [revista  objectForKey:@"nombre_archivo" ]  ];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:archivoDescargar];
    
    
//    fileExists = NO;
    
    if (!fileExists) {
        
        /// loading
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = @"Descargando revista";
        self.hud.dimBackground = YES;
        
        
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        
        
        NSProgress *progress;
        
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            self.hud.hidden=  YES ;
            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            
        }];
        
      
        
        [downloadTask resume];

        
        
      
        [downloadTask resume];
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        
        
        
    }else{
        
        [self cargarPdf: archivoDescargar ];
        
    }
}





- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}






-(IBAction)mostrarDetalle:(id)sender{
    
    [self performSegueWithIdentifier:@"detalle" sender:self ];
}




/// funcion para eliminar un archivo
- (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}




@end
