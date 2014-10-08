//
//  RevistaDB.m
//  TradingRisk
//
//  Created by Hector on 10/2/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import "RevistaDB.h"
#import "RevistaEntity.h"

@implementation RevistaDB



static RevistaDB *_database;

+ (RevistaDB*)database {
    if (_database == nil) {
        _database = [[RevistaDB alloc] init];
    }
    return _database;
}


- (id)init {
    if ((self = [super init])) {
        
           NSString *sourcePath = @"";
        
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString *targetPath = [libraryPath stringByAppendingPathComponent:@"revistas.sqlite3"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            // database doesn't exist in your library path... copy it from the bundle
            sourcePath = [[NSBundle mainBundle] pathForResource:@"revistas" ofType:@"sqlite3"];
            NSError *error = nil;
            
            if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:targetPath error:&error]) {
                NSLog(@"Error: %@", error);
            }
        }
//        
//        
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"revistas"
//                                                             ofType:@"sqlite3" ];
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"revistas.sqlite3"];
        
        if (sqlite3_open([targetPath UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    
    
    
    
//    
//    
//    NSString *docsDir;
//    NSArray *dirPaths;
//    
//    // Get the documents directory
//    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    docsDir = [dirPaths objectAtIndex:0];
//    
//    // Build the path to the database file
//    databasePath = [[NSString alloc] initWithString:
//                    [docsDir stringByAppendingPathComponent:@"revistas.sqlite3"]];
//    
//    NSFileManager *filemgr = [NSFileManager defaultManager];
//    
//    //the file will not be there when we load the application for the first time
//    //so this will create the database table
//    if ([filemgr fileExistsAtPath: databasePath ] == NO)
//    {
//        const char *dbpath = [databasePath UTF8String];
//        if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
//        {
//            char *errMsg;
//            NSString *sql_stmt = @"CREATE TABLE IF NOT EXISTS EMPLOYEES (";
//            sql_stmt = [sql_stmt stringByAppendingString:@"id INTEGER PRIMARY KEY AUTOINCREMENT, "];
//            sql_stmt = [sql_stmt stringByAppendingString:@"name TEXT, "];
//            sql_stmt = [sql_stmt stringByAppendingString:@"department TEXT, "];
//            sql_stmt = [sql_stmt stringByAppendingString:@"age TEXT)"];
//            
//            if (sqlite3_exec(_database, [sql_stmt UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
//            {
//                NSLog(@"Failed to create table");
//            }
//            else
//            {
//                NSLog(@"Employees table created successfully");
//            }
//            
//            sqlite3_close(_database);
//            
//        } else {
//            NSLog(@"Failed to open/create database");
//        }
//    }
//    
    
    
    
    
    return self;
}




- (NSArray *)getRevistas {
    
    NSMutableArray *revistas = [[NSMutableArray alloc] init];
    NSString *query = @"select * from  revistas";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            int uniqueId = sqlite3_column_int(statement, 0);
            
            char * _codigo_android  = (char *) sqlite3_column_text(statement, 1) ;
            char * _codigo_iphone = (char *) sqlite3_column_text(statement, 2) ;
            char * _descripcion = (char *) sqlite3_column_text(statement, 3) ;
            char * _gratis = (char *) sqlite3_column_text(statement, 4) ;
            char * _id_revista = (char *) sqlite3_column_text(statement, 5) ;
            char * _nombre = (char *) sqlite3_column_text(statement, 6) ;
            char * _url_descarga = (char *) sqlite3_column_text(statement, 7) ;
            char * _url_portada = (char *) sqlite3_column_text(statement, 8) ;
            
            
            NSString * _codigo_android_data  = [[NSString alloc] initWithUTF8String:_codigo_android]   ;
            NSString * _codigo_iphone_data  = [[NSString alloc] initWithUTF8String:_codigo_iphone]   ;
            NSString * _descripcion_data  = [[NSString alloc] initWithUTF8String:_descripcion]   ;
            NSString * _gratis_data  = [[NSString alloc] initWithUTF8String:_gratis]   ;
            NSString * _id_revista_data  = [[NSString alloc] initWithUTF8String:_id_revista]   ;
            NSString * _nombre_data  = [[NSString alloc] initWithUTF8String:_nombre]   ;
            NSString * _url_descarga_data  = [[NSString alloc] initWithUTF8String:_url_descarga]   ;
            NSString * _url_portada_data  = [[NSString alloc] initWithUTF8String:_url_portada]   ;
            
            
            RevistaEntity *data = [[RevistaEntity alloc] init ];
            [data setCodigo:uniqueId];
            [data setCodigo_android:_codigo_android_data];
            [data setCodigo_iphone:_codigo_iphone_data];
            [data setDescripcion:_descripcion_data];
            [data setGratis:_gratis_data];
            [data setId_revista:_id_revista_data];
            [data setNombre:_nombre_data];
            [data setUrl_descarga:_url_descarga_data];
            [data setUrl_portada:_url_portada_data];
            
            [revistas addObject:data];
            
        }
        sqlite3_finalize(statement);
    }
    return revistas;
    
}



- (NSString *)getVersion {
    NSString* version = @"0";
    NSMutableArray *revistas = [[NSMutableArray alloc] init];
    NSString *query = @"select * from  version ";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char * _version  = (char *) sqlite3_column_text(statement, 0) ;
            version  = [[NSString alloc] initWithUTF8String:_version]   ;
        }
        sqlite3_finalize(statement);
    }
    return version;
}



- (void )actualizarVersion:(NSString*) version {
    
    
    
    NSString *query = @"delete from  version ";
  
    
    sqlite3_stmt *statement;
    
    NSLog(@" query a ejecutar  %@",query);
    const char *delete_stmt = [query UTF8String];
    sqlite3_prepare_v2(_database, delete_stmt, -1, &statement, NULL);
    
    if(sqlite3_step(statement)==SQLITE_DONE)
    {
        NSLog(@"borrado elementos");
    }
    else
    {
        NSLog(@"error eliminando registros ");
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
    }
    int success=sqlite3_step(statement);
    
    if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(_database));
    }        sqlite3_finalize(statement);

    
    
    
    
    query =  [NSString stringWithFormat:@" insert into version values('%@')" ,  version  ];
    
    NSLog(@" query a ejecutar  %@",query);
    const char *insert_stmt = [query UTF8String];
    sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
    
    if(sqlite3_step(statement)==SQLITE_DONE)
    {
        NSLog(@"insertar version correcta ");
    }
    else
    {
        NSLog(@"error insertar version ");
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
    }
     success=sqlite3_step(statement);
    
    if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(_database));
    }        sqlite3_finalize(statement);
    
    
    
    
    
    
    
    
    
    
    query =  [NSString stringWithFormat:@" delete from revistas "   ];
    
    NSLog(@" query a ejecutar  %@",query);
    insert_stmt = [query UTF8String];
    sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
    
    if(sqlite3_step(statement)==SQLITE_DONE)
    {
        NSLog(@"insertar version correcta ");
    }
    else
    {
        NSLog(@"error insertar version ");
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
    }
    success=sqlite3_step(statement);
    
    if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(_database));
    }        sqlite3_finalize(statement);
    
    
    
    
}








//
//
- (void) grabarRevista:(NSDictionary*) revista
{
    
    NSString *query = [NSString stringWithFormat: @"INSERT INTO revistas ( \n"
                       "codigo_android  ,\n"
                       "codigo_iphone  ,\n"
                       "descripcion  ,\n"
                       "gratis  ,\n"
                       "id   ,\n"
                       "nombre  ,\n"
                       "url_descarga   ,\n"
                       "url_portada  ) \n"
                       " values (  '%@' ,'%@' ,'%@' ,'%@' ,'%@' ,'%@' ,'%@' ,'%@'    ) \n" ,
                       [revista objectForKey:@"codigo_android"   ] ,
                       [revista objectForKey:@"codigo_iphone" ] ,
                       [revista objectForKey:@"descripcion" ] ,
                       [revista objectForKey:@"gratis" ] ,
                       [revista objectForKey:@"id" ] ,
                       [revista objectForKey:@"nombre" ] ,
                       [revista objectForKey:@"url_descarga" ],
                       [revista objectForKey:@"url_portada" ]
                       ];
    
        NSLog(@"query para insertar %@ \n\n" , query); 
    
        sqlite3_stmt *statement;
    
        NSLog(@"%@",query);
        const char *insert_stmt = [query UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            NSLog(@"insert success");
        }
        else
        {
            NSLog(@"insert un success");
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
        }
        int success=sqlite3_step(statement);
        
        if (success == SQLITE_ERROR)
        {
            NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(_database));
        }        sqlite3_finalize(statement);

    
}






- (void)dealloc {
    sqlite3_close(_database);
    
}


@end
