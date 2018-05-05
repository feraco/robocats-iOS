/*  File Version: 3.0
 *	Copyright Chris Ruddell, www.churchphoneapps.com
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the
 *	following disclaimer.
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list
 *	of conditions and the following disclaimer in the documentation and/or other materials
 *	provided with the distribution.
 *
 *	Neither the name of David Book, or buzztouch.com nor the names of its contributors
 *	may be used to endorse or promote products derived from this software without specific
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 *	OF SUCH DAMAGE.
 */

#import "BT_database.h"

@implementation BT_database
@synthesize sharedDataBase, databaseName;

+(void)initDatabase:(NSString *)databaseName{
    //this does nothing
}

//gets the path to the database.  Used by methods in this class - should not be used by parent class.
-(NSString *)dataFilePath {
    if (databaseName.length >0) {
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"dataFilePath: %@", [documentsDirectory stringByAppendingPathComponent:databaseName]]];
        
        return [documentsDirectory stringByAppendingPathComponent:databaseName];
    
    }else {
     
        databaseName = @"BTdefaultDB";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"dataFilePath: %@", [documentsDirectory stringByAppendingPathComponent:databaseName]]];
        return [documentsDirectory stringByAppendingPathComponent:databaseName];
    
    }
}


/*
 creates a database (if needed) and associated table
 uses NSArray of column names.  This NSArray should be filled with NSArray objects like so:
 NSArray *column1 = [[NSArray alloc]initWithObjects:@"fullName", @"TEXT", nil];
 NSArray *column2 = [[NSArray alloc]initWithObjects:@"theAge", @"INTEGER", nil];
 NSArray *columnNames = [[NSArray alloc]column1, column2, nil];
*/
-(void)createDataBasewithTable:(NSString *)tableName andColumnNames:(NSArray *)columnNames{
    
    //-------------------- Create or Open the dataBase if already exists -----------------
    [self OpenDataBase];
    
    //check if keyNames contains a key called "ID"
    for (int i=0; i<columnNames.count; i++) {
        NSArray *tmpKey = [columnNames objectAtIndex:i];
        NSString *tmpKeyName = [tmpKey objectAtIndex:0];
        if ([tmpKeyName isEqualToString:@"ID"]){
            [BT_debugger showIt:self message:@"Error: keyNames array must not contain a key with name 'ID'"];
            return;
        }
    }
    
    //--------------------- Table Creation SOL ---------------------------------
    NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@"
    "(ID INTEGER PRIMARY KEY AUTOINCREMENT", tableName];
    for (int i=0; i<columnNames.count; i++) {
        NSArray *tmpKey = [columnNames objectAtIndex:i];
        createSQL = [createSQL stringByAppendingString:[NSString stringWithFormat:@", %@ %@", [tmpKey objectAtIndex:0], [tmpKey objectAtIndex:1]]];
    }
    createSQL = [createSQL stringByAppendingString:@");"];
    
    char *errorMsg;
    if(sqlite3_exec(sharedDataBase, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK){
        sqlite3_close(sharedDataBase);
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error creating table: %s", errorMsg]];
    }
    
}

-(void)OpenDataBase{
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &sharedDataBase)!= SQLITE_OK) {
        sqlite3_close(sharedDataBase);
        NSAssert(0, @"Failed to open database");
    }
}

/*
 Inserts data into database.
 Takes NSString with table name, and NSDictionary with values and keys, both of which should be NSString objects.
 */
-(void)insertIntoTable: (NSString *)tableName withColumnsAndValues: (NSDictionary *)columnsAndArray{
    
    //use this to manually populate plugin the first time the screen is opened in the app.
    
    NSArray *allKeys = [columnsAndArray allKeys];
    NSString * sqlStatment = [NSString stringWithFormat:@"INSERT INTO %@ ('%@'", tableName, [allKeys objectAtIndex:0]];
    for (int i=1; i<allKeys.count; i++) {
        sqlStatment = [sqlStatment stringByAppendingString:[NSString stringWithFormat:@", '%@'", [allKeys objectAtIndex:i]]];
    }
    sqlStatment = [sqlStatment stringByAppendingString:[NSString stringWithFormat:@") values ('%@'", [columnsAndArray valueForKey:[allKeys objectAtIndex:0]]]];
    for (int i=1; i<allKeys.count; i++) {
        sqlStatment = [sqlStatment stringByAppendingString:[NSString stringWithFormat:@", '%@'", [columnsAndArray valueForKey:[allKeys objectAtIndex:i]]]];
    }
    sqlStatment = [sqlStatment stringByAppendingString:@");"];
    [BT_debugger showIt:self message:sqlStatment];
    
     [self executeQuery:sqlStatment];
     
}


 //executes a valid SQL statement
 
-(void)executeQuery:(NSString *)SqlQuery{
    
    [self OpenDataBase];
    [BT_debugger showIt:self message:SqlQuery];
    
    char *errorMsg;
    if(sqlite3_exec(sharedDataBase, [SqlQuery UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK){
        sqlite3_close(sharedDataBase);
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"error executing query:%s", errorMsg]];
    }
}


//deletes all entries from the table where a certain column is equal to specified value
-(void)deleteEntryWhereColumn: (NSString *)columnName isEqualToValue: (NSString *)theValue fromTable: (NSString *)tableName {
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'", tableName, columnName, theValue];
    [self executeQuery:deleteSQL];
}

//updates the records in the table for all entries where a certain column is equal to a specified value
-(void)updateTable: (NSString *)tableName setColumnsAndValues: (NSDictionary *)columnsAndValuesToUpdate whereColumnsEqualValues: (NSDictionary *)filterByColumnsAndValues {
    NSArray *allKeysToUpdate = [columnsAndValuesToUpdate allKeys];
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ set %@ = '%@'", tableName, [allKeysToUpdate objectAtIndex:0], [columnsAndValuesToUpdate valueForKey:[allKeysToUpdate objectAtIndex:0]]];
    for (int i=1; i<allKeysToUpdate.count; i++) {
        updateSQL = [updateSQL stringByAppendingString:[NSString stringWithFormat:@", %@ = '%@'", [allKeysToUpdate objectAtIndex:i], [columnsAndValuesToUpdate valueForKey:[allKeysToUpdate objectAtIndex:i]]]];
    }
    NSArray *allKeysToFilter = [filterByColumnsAndValues allKeys];
    updateSQL = [updateSQL stringByAppendingString:[NSString stringWithFormat:@" where %@ = '%@'", [allKeysToFilter objectAtIndex:0], [filterByColumnsAndValues valueForKey:[allKeysToFilter objectAtIndex:0]]]];
    for (int i=1; i<allKeysToFilter.count; i++) {
        updateSQL = [updateSQL stringByAppendingString:[NSString stringWithFormat:@", %@ = '%@'", [allKeysToFilter objectAtIndex:i], [filterByColumnsAndValues valueForKey:[allKeysToFilter objectAtIndex:i]]]];
    }
    updateSQL = [updateSQL stringByAppendingString:@";"];
    
    [self executeQuery:updateSQL];
    
}

//returns all column names in table
- (NSArray*)allColumnNamesInTableNamed:(NSString*)tableName {
    // Will return nil if fails, empty array if no columns
    
    //open database
    [self OpenDataBase];
    
    char* errMsg = NULL ;
    int result ;
    
    NSString* statement ;
    
    statement = [[NSString alloc] initWithFormat:@"pragma table_info(%@)", tableName] ;
    
    char** results ;
    int nRows ;
    int nColumns ;
    result = sqlite3_get_table(
                               sharedDataBase,        /* An open database */
                               
                               [statement UTF8String], /* SQL to be executed */
                               &results, /* Result is in char *[] that this points to */
                               &nRows, /* Number of result rows written here */
                               &nColumns, /* Number of result columns written here */
                               
                               &errMsg    /* Error msg written here */
                               ) ;
    
    
    NSMutableArray* columnNames = nil ;
    if (!(result == SQLITE_OK)) {
        // Invoke the error handler for this class
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"There was an error accessing the database.  The error code is: %i", result]];
        [BT_debugger showIt:self message:[NSString stringWithFormat:@"The error message is:%s", errMsg]];
    }
    else {
        int j ;
        for (j=0; j<nColumns; j++) {
            if (strcmp(results[j], "name") == 0) {
                break ;
            }
        }
        if (j<nColumns) {
            int i ;
            columnNames = [[NSMutableArray alloc] init] ;
            for (i=0; i<nRows; i++) {
                
                [columnNames addObject:[NSString stringWithUTF8String:results[(i+1)*nColumns + 1]]] ;
                
            }
        }
    }
    sqlite3_free_table(results) ;
    
    NSArray* output = nil ;
    if (columnNames != nil) {
        output = [columnNames copy] ;
    }
    
    return output;
}

//returns an array of dictionaries of all data from the table.  Dictionary will consist of:
//columnname : value
-(NSArray *)getAllDataFromTable: (NSString *)tableName {
    //open dataBase
    [self OpenDataBase];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    
    sqlite3_stmt *statement;
    
    NSArray *columnNames = [self allColumnNamesInTableNamed:tableName];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    if(sqlite3_prepare_v2(sharedDataBase, [selectSQL UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        while(sqlite3_step(statement) ==SQLITE_ROW)
        {
            NSMutableDictionary *theData = [[NSMutableDictionary alloc]init];
            for (int i=0; i<columnNames.count; i++) {
                char *theField = (char *) sqlite3_column_text(statement, i);
                NSString *fieldStr=[[NSString alloc]initWithUTF8String:theField];
                [theData setValue:fieldStr forKey:[columnNames objectAtIndex:i]];
            }
            [results addObject:theData];
        }
        
        
    }
    return results;
}

//returns a dictionary of all data from table where specified columns contain specified values
-(NSArray *)getDataFromTable: (NSString *)tableName whereColumnEqualsValue: (NSDictionary *)columnsAndValues {
    //open dataBase
    [self OpenDataBase];
    
    NSArray *allKeys = [columnsAndValues allKeys];
    NSMutableArray *results = [[NSMutableArray alloc]init];

    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableName, [allKeys objectAtIndex:0], [columnsAndValues valueForKey:[allKeys objectAtIndex:0]] ];
    for (int i=1; i<allKeys.count; i++) {
    query = [query stringByAppendingString:[NSString stringWithFormat:@" and %@ = '%@'", [allKeys objectAtIndex:i], [columnsAndValues valueForKey:[allKeys objectAtIndex:i]]]];
    }
    
    query = [query stringByAppendingString:[NSString stringWithFormat:@";"]];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(sharedDataBase, [query UTF8String],-1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *theData = [[NSMutableDictionary alloc]init];
            for (int i=0; i<allKeys.count; i++) {
                char *rowData = (char *)sqlite3_column_text(statement, i);
                NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];
                [theData setValue:fieldValue forKey:[allKeys objectAtIndex:i]];
            }
            [results addObject:theData];
            
        } sqlite3_finalize(statement);
    }
    
    return results;
}

//returns a dictionary of specified column data where specified columns contain specified values
-(NSArray *)getDataFromTable: (NSString *)tableName forColumns: (NSArray *)theColumns {
    //open dataBase
    [self OpenDataBase];
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    NSString *query = [NSString stringWithFormat:@"select %@", [theColumns objectAtIndex:0] ];
    for (int i=1; i<theColumns.count; i++) {
        query = [query stringByAppendingString:[NSString stringWithFormat:@", %@", [theColumns objectAtIndex:i]]];
    }
    
    query = [query stringByAppendingString:[NSString stringWithFormat:@" from %@", tableName]];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(sharedDataBase, [query UTF8String],-1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary *theData = [[NSMutableDictionary alloc]init];
            for (int i=0; i<theColumns.count; i++) {
                char *rowData = (char *)sqlite3_column_text(statement, i);
                NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];
                [theData setValue:fieldValue forKey:[theColumns objectAtIndex:i]];
            }
            [results addObject:theData];
            
        } sqlite3_finalize(statement);
    }
    
    return results;
}

//closes the database
-(void)closeDataBase{
    
    sqlite3_close(sharedDataBase);
    
}
@end











