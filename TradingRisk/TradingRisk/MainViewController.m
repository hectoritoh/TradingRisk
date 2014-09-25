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

#import "DescargarViewController.h"
#import "UIImageView+AFNetworking.h"


@interface MainViewController () <ReaderViewControllerDelegate>

@end

@implementation MainViewController


NSArray *_products;
NSMutableArray *_revistas;
NSMutableArray *  slider_images;

NSString* titulo_selected ;

NSMutableArray *  revistas_data;



/**
 *  url del servicio
 */
NSString *url_servicio = @"http://190.98.210.200/TradingRisk/wsdl.php" ;


/*
 url basicas para consultar las imagenes y las revistas
 */
NSString* url_base_slide    = @"http://190.98.210.200/TradingRisk/Archivos/img/";
NSString* url_base_revista  = @"http://190.98.210.200/TradingRisk/Archivos/revistas/";
NSString* url_base_portada    = @"http://190.98.210.200/TradingRisk/Archivos/portadas/";

// url de la revista que se va a descargar
NSString* url_selected ;

// url de la portada que se va a descargar
NSString* url_portada_selected ;


// controlador del slider
ReaderViewController *readerViewController;

// controlador del slider
PagedImageScrollView *pageScrollView ;



/**
 *  Esta funcion carga el slider principal, primero hace request de las ruta de las imagenes y luego las carga
 *  de forma asincronica
 */
-(void) cargarSlider{
    
    
    slider_images = [[NSMutableArray alloc] init];
    
    NSMutableArray* imagenes    = [[NSMutableArray alloc] init];
    NSMutableArray* url_banners = [[NSMutableArray alloc] init];
    
 
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"user": @"trading"  , @"pass": @"riskclave"  , @"metodo": @"slider"  };
    [manager POST:  url_servicio  parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            //// respuesta de la version de los slider
            NSString * version = [  responseObject objectForKey:@"version" ];
            
            NSDictionary* data_banners =  [self indexKeyedDictionaryFromArray: [responseObject objectForKey:@"banner" ]  ] ;
            
            for (NSString* key in data_banners) {
                
                id value = [data_banners objectForKey:key];
                
                NSString* nombre_archivo = [NSString stringWithFormat:@"%@%@" , url_base_slide , [value valueForKey:@"url_banner" ] ];
                
                nombre_archivo=[nombre_archivo stringByReplacingOccurrencesOfString:@".png" withString:@".jpg"];
                
                [url_banners addObject:nombre_archivo];
                
                UIImageView* img_banner = [[ UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner.png"]];
                
                [imagenes addObject:img_banner];
                
                NSLog(@"archivo banner %@" , nombre_archivo);
                
                
            }
            [pageScrollView setScrollViewContentsImageViews: imagenes  andUrls: url_banners  ];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error description ]);
    }];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
      [self.navigationController setTitle:@"Trading Risk"];
    
    revistas_data = [[NSMutableArray alloc] init] ;
    
    
    pageScrollView = [[PagedImageScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    [pageScrollView setScrollViewContents:@[[UIImage imageNamed:@"banner.png"] ]];
    
    pageScrollView.pageControlPos = PageControlPositionCenterBottom;
    [self.view addSubview:pageScrollView];
    
    

    
    _tableview = (UITableView*) [ self.view viewWithTag:10 ];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    
    
    [self.verInfo setAction:@selector(mostrarInfoTradingRisk)];
    [self.verInfo setTarget:self]; 
    
    
    self.toolbar.delegate = self ; 
  
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [_tableview addSubview:self.refreshControl];
    
    [self reload];
    [self.refreshControl beginRefreshing];
    
    
    /**
     *  timer que escogen los hud de loading en eventos de carga
     */
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(acciones) userInfo:nil repeats:YES];
    
    
    [self cargarSlider ];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)reload {
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Actualizando catalogo";
    self.hud.dimBackground = YES;
    
    
    NSString *url_servicio = @"http://190.98.210.200/TradingRisk/wsdl.php" ;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"user": @"trading"  , @"pass": @"riskclave"  , @"metodo": @"revista"  };
    [manager POST:  url_servicio  parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSLog(@"class %@ " , [responseObject class ]  );
        
        revistas_data = [responseObject objectForKey:@"revistas"];
        
        NSLog(@"data de la revista %@ ", revistas_data);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error description ]);
    }];
    
    
//    _products = nil;
    

    
    
    
    
     
    
    [[TradingRiskIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [_tableview reloadData];
            [self.hud hide:YES ];
            
            [self.tableview reloadData];
        }else{
            
            
            [self.hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Error de conexion"
                                                           message: @"Problemas al cargar items"
                                                          delegate: self
                                                 cancelButtonTitle:@"Reintentar"
                                                 otherButtonTitles:nil,nil];
            
            
            [alert show];
            
            [self.tableview reloadData];
            
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
    return revistas_data.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return 90.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    UIView* view = (UIView *) [cell viewWithTag:123 ];
    UILabel* titulo = (UILabel *) [cell viewWithTag:10 ];
    UILabel* precio = (UILabel*) [  cell viewWithTag:20];
    UIImageView* img_portada = (UIImageView*)[  cell viewWithTag:300 ];
    
    UIButton* accion = (UIButton*) [ cell viewWithTag:30 ];
    
    
    NSLog(@"configuracion de celdas");
    NSLog(@"configurando la celda de indice %d" , indexPath.row );
    
    SKProduct * product = (SKProduct *) _products[ indexPath.row ];

    // border redondeados especificados mediante codigo
    [view.layer setCornerRadius:5.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:0.5f];
    
    
    NSDictionary * data = revistas_data[  indexPath.row  ] ;
    
    
    // seteo del titulo
    titulo.text = [ data objectForKey:@"nombre" ] ;
    
    // seteo del precio
    precio.text = [ NSString stringWithFormat:@"$%@" , product.price];
    
    // url de la portada
    NSString* url_portada = [self getRutaDescargaDe:@"portada" delIndice:indexPath.row];
    [img_portada setImageWithURL:[NSURL URLWithString: url_portada  ]];
    
    // url de la descarga
    NSString* url_revista_descarga = [self   getRutaDescargaDe:@"revista" delIndice:indexPath.row];
    
    
    // verifica si el producto ha sido comprado
    
    if ([[TradingRiskIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        
        
        
        if ([self verificarDescargaArchivo:url_revista_descarga]) {
            
            [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
            [accion addTarget:self action:@selector(leerRevista:) forControlEvents:UIControlEventTouchUpInside];
            
            NSLog(@"  revista %@ , comprada y descargada " ,  titulo.text );
            
        }else{
            /// DESCARGA DE ARCHIVO
            [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
            [accion addTarget:self action:@selector(descargar:) forControlEvents:UIControlEventTouchUpInside];
            
                        NSLog(@"  revista %@ , comprada y no  descargada " ,  titulo.text );
        }
        
    } else {
        
        NSLog(@"  revista %@ , no comprada " ,  titulo.text );
        //// opcion de compra
        [accion addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return cell;
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell.contentView.layer setCornerRadius:7.0f];
    [cell.contentView.layer setMasksToBounds:YES];
}



- (void)buyButtonTapped:(id)sender {
    
    
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Realizando transacción";
    self.hud.dimBackground = YES;
    
    
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




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    
    
    if (![[segue identifier] isEqualToString:@"mostrarInfo"])
    {
        
    DescargarViewController *vc = [segue destinationViewController];
    
    [vc setTitulo:  titulo_selected ];
    [vc setRuta_descarga:url_selected];
    [vc setRuta_portada: url_portada_selected ];
    }
}



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




#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    NSLog(@"Cerrando");
	[self dismissViewControllerAnimated:YES completion:NULL];
    
}



-(void) leerRevista:(id)sender {

    
    UITableViewCell *clickedCell = (UITableViewCell *)[[[[sender superview] superview] superview ]  superview];
    NSIndexPath *clickedButtonIndexPath = [self.tableview indexPathForCell:clickedCell];
    
    
    NSString* ruta = [self getRutaDescargaDe:@"revista" delIndice: clickedButtonIndexPath.row ];
    
    
    NSString* theFileName = [[NSFileManager defaultManager] displayNameAtPath:ruta ] ;
    

    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* archivoDescargar = [documentsPath stringByAppendingPathComponent: theFileName  ];
    
    BOOL existe =   [[NSFileManager defaultManager] fileExistsAtPath:archivoDescargar];
    
    
    
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
	NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:archivoDescargar password:phrase];

    
//	ReaderDocument *document = [ReaderDocument withDocumentFilePath:archivoDescargar password:nil];
    
	if (document != nil)
	{
		readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
		[self presentViewController:readerViewController animated:YES completion:NULL];
        
	}
    


}





/**
 *  muestra la pantalla de descarga de la revista
 *
 *  @param sender elemento que invoca la accion
 */
-(IBAction)descargar:(id)sender{
    
    UITableViewCell *clickedCell = (UITableViewCell *)[[[[sender superview] superview] superview ]  superview];
    NSIndexPath *clickedButtonIndexPath = [self.tableview indexPathForCell:clickedCell];
    
    NSLog(@"Evento de descarga lanzado indice %ld" , (long)[clickedButtonIndexPath row] );
    
    
    NSString* ruta = [self getRutaDescargaDe:@"revista" delIndice: clickedButtonIndexPath.row ];
    
    
//    NSDictionary* revista = [ _revistas objectAtIndex: [ clickedButtonIndexPath row  ] ];
//    NSURL *URL = [NSURL URLWithString: [revista  objectForKey:@"url_descarga" ]   ];
//    
    NSURL *URL = [NSURL URLWithString: ruta   ];
    
    SKProduct * product = (SKProduct *) _products[clickedButtonIndexPath.row];
    
    
    NSDictionary* data = [  revistas_data objectAtIndex: clickedButtonIndexPath.row  ];
    url_selected = [ NSString stringWithFormat:@"%@%@" , url_base_revista , [data objectForKey:@"url_descarga" ]  ];
    NSLog(@" url descarga revista %@" , url_selected );
    
    url_selected = ruta ;
    
    
    url_portada_selected = [ NSString stringWithFormat:@"%@%@" , url_base_portada , [data objectForKey:@"url_portada" ]  ];
    NSLog(@" url descarga revista %@" , url_selected );
    url_portada_selected = [self getRutaDescargaDe:@"portada" delIndice: clickedButtonIndexPath.row ];
    
    
    titulo_selected = product.localizedTitle;
//    url_selected = [revista  objectForKey:@"url_descarga" ]   ;
    
    
    [self performSegueWithIdentifier:@"descarga" sender:self ];
}






-(void) acciones{
    
    

    NSUserDefaults* defaults = [NSUserDefaults  standardUserDefaults ];
    NSString* cerrar = [ defaults objectForKey:@"cerrar" ];
    NSString* recargar = [ defaults objectForKey:@"recargar" ];
    
    if (cerrar != nil) {
        [self.hud hide:YES];
        [ defaults setObject:nil forKey:@"cerrar"];
        [defaults synchronize ];
        NSLog(@"Cerrar  ");
    }
    
    if (recargar != nil) {
        
//        [self reload];
        [self.tableview reloadData];

        [ defaults setObject:nil forKey:@"recargar"];
        [defaults synchronize ];
    }
    
    
}



- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array
{
    id objectInstance;
    NSUInteger indexKey = 0U;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array)
        [mutableDictionary setObject:objectInstance forKey:[NSNumber numberWithUnsignedInt:indexKey++]];
    
    return (NSDictionary *)mutableDictionary ;
}






-(BOOL) verificarDescargaArchivo:(NSString*) ruta_archivo {

//    NSString* theFileName = [[  ruta_archivo   lastPathComponent] stringByDeletingLastPathComponent ];
    NSString* theFileName = [  ruta_archivo   pathExtension ];
    theFileName = [[NSFileManager defaultManager] displayNameAtPath: ruta_archivo ];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* archivoDescargar = [documentsPath stringByAppendingPathComponent: theFileName  ];
    
    return  [[NSFileManager defaultManager] fileExistsAtPath:archivoDescargar];

}




-(NSString*) getRutaDescargaDe:(NSString*) tipo_de_ruta delIndice:(NSUInteger) indice{
    
    NSDictionary* data = [revistas_data objectAtIndex:indice] ;
    NSString* url = @"";
    
    if ([tipo_de_ruta isEqualToString:@"portada"]) {
        url = [[NSString alloc] initWithFormat:@"%@%@" , url_base_portada , [data objectForKey:@"url_portada"] ];
    }
    
    if ([tipo_de_ruta isEqualToString:@"revista"]) {
        url = [[NSString alloc] initWithFormat:@"%@%@" , url_base_revista , [data objectForKey:@"url_descarga"] ];
    }
    
    return url ;
    
}



-(IBAction)mostrarInfo:(id)sender{

    [self performSegueWithIdentifier:@"mostrarInfo" sender:self];

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{

    NSLog(@"test");
}


@end
