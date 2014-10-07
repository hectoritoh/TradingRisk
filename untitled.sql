        "codigo_android" = "com.celmedia.tradingrisk";
        "codigo_iphone" = "mi.revista.14";
        descripcion = "Esta es la descripcion de la revista 14";
        gratis = no;
        id = "celmedia_td_000014";
        nombre = "Magazine 14";
        "url_descarga" = "demo14.pdf";
        "url_portada" = "revista2.JPG";



        0989949132

        create table revistas(   codigo INTEGER PRIMARY KEY, 
        						codigo_android text , 
        						codigo_iphone text , 
        						descripcion text , 
        						gratis text , 
        						id  text , 
        						nombre text ,
        						url_descarga text  , 
        						url_portada text )

        insert into revistas(codigo_android , codigo_iphone , descripcion , gratis , id  , nombre , url_descarga , url_portada) values('' , '' , '' , '' , '' , '' , '' , '' ); 


        select * from  revistas




        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO revistas (
                               codigo_android  ,
                               codigo_iphone  ,
                               descripcion  ,
                               gratis  ,
                               id   ,
                               nombre  ,
                               url_descarga   ,
                               url_portada  ) VALUES (\"%@\", \"%@\", \"%@\")", name.text, address.text, phone.text];



NSString * _codigo_android ;
NSString * _codigo_iphone;
NSString * _descripcion;
NSString * _gratis;
NSString * _id_revista;
NSString * _nombre;
NSString * _url_descarga;
NSString * _url_portada;

NSString * _codigo_android_data  = [[NSString alloc] initWithUTF8String:_codigo_android]   ;
NSString * _codigo_iphone_data  = [[NSString alloc] initWithUTF8String:_codigo_iphone]   ;
NSString * _descripcion_data  = [[NSString alloc] initWithUTF8String:_descripcion]   ;
NSString * _gratis_data  = [[NSString alloc] initWithUTF8String:_gratis]   ;
NSString * _id_revista_data  = [[NSString alloc] initWithUTF8String:_id_revista]   ;
NSString * _nombre_data  = [[NSString alloc] initWithUTF8String:_nombre]   ;
NSString * _url_descarga_data  = [[NSString alloc] initWithUTF8String:_url_descarga]   ;
NSString * _url_portada_data  = [[NSString alloc] initWithUTF8String:_url_portada]   ;


char * _codigo_android  = (char *) sqlite3_column_text(statement, 1) ;
char * _codigo_iphone = (char *) sqlite3_column_text(statement, 2) ;
char * _descripcion = (char *) sqlite3_column_text(statement, 3) ;
char * _gratis = (char *) sqlite3_column_text(statement, 4) ;
char * _id_revista = (char *) sqlite3_column_text(statement, 5) ;
char * _nombre = (char *) sqlite3_column_text(statement, 6) ;
char * _url_descarga = (char *) sqlite3_column_text(statement, 7) ;
char * _url_portada = (char *) sqlite3_column_text(statement, 8) ;



            char *codigo_android = (char *) sqlite3_column_text(statement, 1);