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
#import "RevistaDB.h"
#import "RevistaEntity.h"





@interface MainViewController () <ReaderViewControllerDelegate>

@end

@implementation MainViewController


NSArray        * _products;
NSMutableArray * _revistas;
NSMutableArray * slider_images;

NSString* titulo_selected ;

NSMutableArray *  revistas_data;
NSArray *  revistas_data_db;



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
            
            NSTimer *aTimerSlider = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cambiarSlider) userInfo:nil repeats:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error description ]);
    }];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setTitle:@"Trading Risk"];
    
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;

    revistas_data = [[NSMutableArray alloc] init] ;
    
    
    /**
     Configuracion de slider
     */
    pageScrollView = [[PagedImageScrollView alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 150)];
    [pageScrollView setScrollViewContents:@[[UIImage imageNamed:@"banner.png"] ]];
    
    pageScrollView.pageControlPos = PageControlPositionCenterBottom;
    [self.view addSubview:pageScrollView];
    
    
    /**
     Configuracion de tabla
     */
    
    
    _tableview = (UITableView*) [ self.view viewWithTag:10 ];
    
    self.view.frame = CGRectMake(0, 0 , [[UIScreen mainScreen] bounds].size.width, 44);
    _tableview.frame = CGRectMake(0, 0 , [[UIScreen mainScreen] bounds].size.width, 44);
    
    _tableview.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
    
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    
    
    [self.verInfo setAction:@selector(mostrarInfoTradingRisk)];
    [self.verInfo setTarget:self];
    
    
    
    
    CGRect bot_frame = CGRectMake(0, 0 , [[UIScreen mainScreen] bounds].size.width, 44);
    self.toolbar.delegate = self ;
    self.toolbar.frame = bot_frame ;
    [self.toolbar setBackgroundColor:[UIColor blackColor]];
    
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl setBackgroundColor:[UIColor colorWithRed:164/255 green:164/255 blue:164/255 alpha:1.000]];
    
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
        
        NSString* version =  [responseObject objectForKey:@"version"];
        NSString* version_actual = [[  RevistaDB database] getVersion];
        
        
        if ([version isEqualToString:version_actual]) {
            revistas_data_db = [[  RevistaDB database] getRevistas];
        }else{
        
        [[  RevistaDB database] actualizarVersion: version];
        revistas_data = [responseObject objectForKey:@"revistas"];
        
        NSLog(@"data de la revista %@ ", revistas_data);
        
        
        for (id object_data in revistas_data ) {
            [[RevistaDB database]  grabarRevista:object_data  ];
            }
        }
        
        revistas_data_db = [[  RevistaDB database] getRevistas];
        
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
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error description ]);
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
    return revistas_data_db.count;
}







//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (revistas_data_db.count == (NSUInteger)indexPath.row) {
        return 180;
    }
    
    return 90.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    UIView* view             = (UIView *)       [cell viewWithTag:123 ];
    UILabel* titulo          = (UILabel *)      [cell viewWithTag:10  ];
    UILabel* precio          = (UILabel *)      [cell viewWithTag:20  ];
    UIImageView* img_portada = (UIImageView *)  [cell viewWithTag:300 ];
    UIButton* accion         = (UIButton*)      [cell viewWithTag:30  ];
    
    // border redondeados especificados mediante codigo
    [view.layer setCornerRadius:5.0f];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:0.5f];
    
    
    RevistaEntity * data = revistas_data_db[  indexPath.row  ] ;
    
    
    // seteo del titulo
    titulo.text = [ data nombre ] ;
    
    // url de la portada
    NSString* url_portada = [self getRutaDescargaDe:@"portada" delIndice:indexPath.row];
    [img_portada setImageWithURL:[NSURL URLWithString: url_portada  ]];
    
    
    // url de la descarga

   
    

    NSLog(@"configurando la celda de indice %d  de codigo %@ " , indexPath.row , [data codigo_iphone] );
    

    

    return cell;
}



-(IBAction)accionProducto:(id)sender{

    
    UIButton *accion = (UIButton *)sender;
    
    UITableViewCell *cell = (UITableViewCell *)accion.superview.superview.superview.superview;
    UITableView *tableView = (UITableView *)cell.superview.superview;
    NSIndexPath *clickedButtonIndexPath = [tableView indexPathForCell:cell];
    
    RevistaEntity* data = [revistas_data_db objectAtIndex:  clickedButtonIndexPath.row ];
    SKProduct* producto = [self getProductoPorCodigo:[data codigo_iphone]];
    
    NSString* url_revista_descarga = [self   getRutaDescargaDe:@"revista" delIndice:clickedButtonIndexPath.row];
    
    if (producto == NULL ) {
        
        [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
        [self productoNoDisponible:accion  ];
        
        [accion addTarget:self action:@selector(productoNoDisponible:) forControlEvents:UIControlEventTouchUpInside];
        
//        precio.text = @"";
        
    }else{
        
//        precio.text = [ NSString stringWithFormat:@"$%@" , producto.price];
        
        if ([[TradingRiskIAPHelper sharedInstance] productPurchased:producto.productIdentifier  ]) {
            
            
            if ([self verificarDescargaArchivo:url_revista_descarga]) {
                
                [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
                [self leerRevista:accion];
//                [accion addTarget:self action:@selector(leerRevista:) forControlEvents:UIControlEventTouchUpInside];
                
//                NSLog(@"  revista %@ , comprada y descargada " ,  titulo.text );
                
            }else{
                /// DESCARGA DE ARCHIVO
                [accion setImage:[ UIImage imageNamed:@"read.png" ] forState:UIControlStateNormal];
                [accion addTarget:self action:@selector(descargar:) forControlEvents:UIControlEventTouchUpInside];
                [self descargar:accion];
                
//                NSLog(@"  revista %@ , comprada y no  descargada " ,  titulo.text );
            }
            
        } else {
            
//            NSLog(@"  revista %@ , no comprada " ,  titulo.text );
            [self buyButtonTapped:accion ];
            //// opcion de compra
//            [accion addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }



}



- (void)buyButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview.superview;
    UITableView *tableView = (UITableView *)cell.superview.superview;
    NSIndexPath *clickedButtonIndexPath = [tableView indexPathForCell:cell];


    RevistaEntity* revista = [revistas_data_db objectAtIndex:  clickedButtonIndexPath.row  ];
    SKProduct *product =[self getProductoPorCodigo:  [revista codigo_iphone ]  ] ;
    
    if (product == NULL) {
        [self productoNoDisponible:nil];
    }else{
     
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = @"Realizando transacción";
        self.hud.dimBackground = YES;
        
        NSLog(@"Buying %@...", product.productIdentifier);
        [[TradingRiskIAPHelper sharedInstance] buyProduct:product];
    }
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
	[self dismissViewControllerAnimated:YES completion:NULL];
}



-(void) leerRevista:(id)sender {
    
    UITableViewCell *clickedCell = (UITableViewCell *)[[[[sender superview] superview] superview ]  superview];
    NSIndexPath *clickedButtonIndexPath = [self.tableview indexPathForCell:clickedCell];
    
    NSString* ruta = [self getRutaDescargaDe:@"revista" delIndice: clickedButtonIndexPath.row ];
    NSString* theFileName = [[NSFileManager defaultManager] displayNameAtPath:ruta ] ;
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* archivoDescargar = [documentsPath stringByAppendingPathComponent: theFileName  ];

    
    @try
    {
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:archivoDescargar password:nil ];
        
    if (document != nil)
        {
            readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            readerViewController.delegate = self;
            
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self presentViewController:readerViewController animated:YES completion:NULL];
            
    }
        
    }@catch (NSException *ex) {
    
        [self descargar:sender];
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
    
    
    
    
    
    NSString* theFileName = [[NSFileManager defaultManager] displayNameAtPath:ruta ] ;
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* archivoDescargar = [documentsPath stringByAppendingPathComponent: theFileName  ];
    
//    BOOL existe =   [[NSFileManager defaultManager] fileExistsAtPath:archivoDescargar];
//    if (existe) {
//        NSLog(@"archivo si existe en descarga");
//        return;
//    }
    
    
    
    //    NSDictionary* revista = [ _revistas objectAtIndex: [ clickedButtonIndexPath row  ] ];
    //    NSURL *URL = [NSURL URLWithString: [revista  objectForKey:@"url_descarga" ]   ];
    //
    NSURL *URL = [NSURL URLWithString: ruta   ];
    
//    SKProduct * product = (SKProduct *) _products[clickedButtonIndexPath.row];
    RevistaEntity* data = [revistas_data_db objectAtIndex: clickedButtonIndexPath.row ];
    SKProduct * product = [self getProductoPorCodigo:  [data codigo_iphone] ];
    
    

    
    //url_selected = [ NSString stringWithFormat:@"%@%@" , url_base_revista , [data objectForKey:@"url_descarga" ]  ];
    url_selected = [self getRutaDescargaDe:@"revista" delIndice: clickedButtonIndexPath.row ];
    
    
    NSLog(@" url descarga revista %@" , url_selected );
    
    url_selected = ruta ;
    
    
    url_portada_selected = [ NSString stringWithFormat:@"%@%@" , url_base_portada , [data url_portada ]  ];
    NSLog(@" url descarga revista %@" , url_selected );
    url_portada_selected = [self getRutaDescargaDe:@"portada" delIndice: clickedButtonIndexPath.row ];
    
    
    titulo_selected = product.localizedTitle;
    
    
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
    
    BOOL existe = [[NSFileManager defaultManager] fileExistsAtPath:archivoDescargar];
    return existe;
    
}




-(NSString*) getRutaDescargaDe:(NSString*) tipo_de_ruta delIndice:(NSUInteger) indice{
    
    RevistaEntity* data = [revistas_data_db objectAtIndex:indice] ;
    NSString* url = @"";
    
    if ([tipo_de_ruta isEqualToString:@"portada"]) {
        url = [[NSString alloc] initWithFormat:@"%@%@" , url_base_portada , [data  url_portada ] ];
    }
    
    if ([tipo_de_ruta isEqualToString:@"revista"]) {
        url = [[NSString alloc] initWithFormat:@"%@%@" , url_base_revista , [data url_descarga ] ];
    }
    
    
//    NSDictionary* data = [revistas_data objectAtIndex:indice] ;
//    NSString* url = @"";
//    
//    if ([tipo_de_ruta isEqualToString:@"portada"]) {
//        url = [[NSString alloc] initWithFormat:@"%@%@" , url_base_portada , [data objectForKey:@"url_portada"] ];
//    }
//    
//    if ([tipo_de_ruta isEqualToString:@"revista"]) {
//        url = [[NSString alloc] initWithFormat:@"%@%@" , url_base_revista , [data objectForKey:@"url_descarga"] ];
//    }
    
    return url ;
    
}



-(SKProduct*) getProductoPorCodigo:(NSString*) codigo_iphone {

    for (SKProduct* producto in _products) {
        if ([producto.productIdentifier isEqualToString: codigo_iphone] ) {
            return producto;
        }
    }
    return NULL;
}



-(IBAction)mostrarInfo:(id)sender{
    [self performSegueWithIdentifier:@"mostrarInfo" sender:self];
}



-(IBAction)productoNoDisponible:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Trading Risk"
                                                   message: @"Producto no disponible temporalmente"
                                                  delegate: self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil ,nil];
    
    [alert setTag:1];
    [alert show];
}




- (void)cambiarSlider{
    [pageScrollView cambiarPagina ];
}




@end
