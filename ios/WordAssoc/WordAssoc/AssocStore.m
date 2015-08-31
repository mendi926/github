//
//  AssocStore.m
//  WordAssoc
//
//  Created by Armend H on 03/08/15.
//  Copyright (c) 2015 Armend H. All rights reserved.
//

#import "AssocStore.h"
#import "AssocSet.h"
#import "AssocSetProgress.h"

@import CoreData;

@interface AssocStore()


@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation AssocStore

+ (instancetype)sharedStore
{
    static AssocStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[AssocStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        NSString *path = self.itemArchivePath;
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
            NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"JSON2CD" ofType:@"sqlite"]];
            NSError* err = nil;
            
            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
                NSLog(@"Could not copy preloaded data");
            }
        }
        
        NSError *error;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            @throw [NSException exceptionWithName:@"OpenFailure"
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
        
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = psc;
        
    }
    return self;
}

- (NSString *)itemArchivePath
{

    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (void)loadAssoc:(int)number{
    
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"AssocSet"
                                             inManagedObjectContext:self.context];
        
        request.entity = e;
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"id == %d", number];
       [request setPredicate:p];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];

        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];

        }
    
        AssocSet *assoc = result[0];
        
        self.assocSet = [[NSMutableArray alloc] init];
        
        self.assocSet[0] = assoc.a;
        self.assocSet[1] = assoc.b;
        self.assocSet[2] = assoc.c;
        self.assocSet[3] = assoc.d;
        self.assocSet[4] = assoc.rez;
        
        self.assocSet[5] = assoc.a1;
        self.assocSet[6] = assoc.a2;
        self.assocSet[7] = assoc.a3;
        self.assocSet[8] = assoc.a4;
        self.assocSet[9] = assoc.a;
        
        self.assocSet[10] = assoc.b1;
        self.assocSet[11] = assoc.b2;
        self.assocSet[12] = assoc.b3;
        self.assocSet[13] = assoc.b4;
        self.assocSet[14] = assoc.b;
        
        self.assocSet[15] = assoc.c1;
        self.assocSet[16] = assoc.c2;
        self.assocSet[17] = assoc.c3;
        self.assocSet[18] = assoc.c4;
        self.assocSet[19] = assoc.c;
        
        self.assocSet[20] = assoc.d1;
        self.assocSet[21] = assoc.d2;
        self.assocSet[22] = assoc.d3;
        self.assocSet[23] = assoc.d4;
        self.assocSet[24] = assoc.d;
    
        self.assocSet[25] = assoc.id;
    
}

- (void)loadAssocProgress:(int)number {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *e = [NSEntityDescription entityForName:@"AssocSetProgress"
                                         inManagedObjectContext:self.context];
    
    request.entity = e;
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"id == %d", number];
    [request setPredicate:p];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    
    if ([result count] == 0) {
        
        _assocSetProgress = [NSMutableArray arrayWithArray:@[@"ZGJIDHJA A", @"ZGJIDHJA B", @"ZGJIDHJA C", @"ZGJIDHJA D", @"ZGJIDHJA", @"A1", @"A2", @"A3", @"A4",@"ZGJIDHJA A", @"B1", @"B2", @"B3", @"B4",@"ZGJIDHJA B", @"C1", @"C2", @"C3", @"C4", @"ZGJIDHJA C", @"D1", @"D2", @"D3", @"D4", @"ZGJIDHJA D", [NSNumber numberWithInt:number]]];
        
        return;
        
    }
    
    AssocSetProgress *assoc = result[0];
    
    self.assocSetProgress = [[NSMutableArray alloc] init];
    
    self.assocSetProgress[0] = assoc.a;
    self.assocSetProgress[1] = assoc.b;
    self.assocSetProgress[2] = assoc.c;
    self.assocSetProgress[3] = assoc.d;
    self.assocSetProgress[4] = assoc.rez;
    
    self.assocSetProgress[5] = assoc.a1;
    self.assocSetProgress[6] = assoc.a2;
    self.assocSetProgress[7] = assoc.a3;
    self.assocSetProgress[8] = assoc.a4;
    self.assocSetProgress[9] = assoc.a;
    
    self.assocSetProgress[10] = assoc.b1;
    self.assocSetProgress[11] = assoc.b2;
    self.assocSetProgress[12] = assoc.b3;
    self.assocSetProgress[13] = assoc.b4;
    self.assocSetProgress[14] = assoc.b;
    
    self.assocSetProgress[15] = assoc.c1;
    self.assocSetProgress[16] = assoc.c2;
    self.assocSetProgress[17] = assoc.c3;
    self.assocSetProgress[18] = assoc.c4;
    self.assocSetProgress[19] = assoc.c;
    
    self.assocSetProgress[20] = assoc.d1;
    self.assocSetProgress[21] = assoc.d2;
    self.assocSetProgress[22] = assoc.d3;
    self.assocSetProgress[23] = assoc.d4;
    self.assocSetProgress[24] = assoc.d;
    
    self.assocSetProgress[25] = assoc.id;
}

- (void)insertLoadAssocProgress:(NSMutableArray *)assocSetProgress indexNumber:(int)number{
    
    AssocSetProgress *assoc;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *e = [NSEntityDescription entityForName:@"AssocSetProgress"
                                         inManagedObjectContext:self.context];
    
    request.entity = e;
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"id == %d", number];
    [request setPredicate:p];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    
    if ([result count] == 0) {
        
       assoc = [NSEntityDescription insertNewObjectForEntityForName:@"AssocSetProgress"
                                                                inManagedObjectContext:self.context];
    }else{
        
       assoc = result[0];
    }
    

    
    self.assocSetProgress = [NSMutableArray arrayWithArray:assocSetProgress];
    
    assoc.a = self.assocSetProgress[0];
    assoc.b = self.assocSetProgress[1];
    assoc.c = self.assocSetProgress[2];
    assoc.d = self.assocSetProgress[3];
    assoc.rez = self.assocSetProgress[4];
    
    assoc.a1 = self.assocSetProgress[5];
    assoc.a2 = self.assocSetProgress[6];
    assoc.a3 = self.assocSetProgress[7];
    assoc.a4 = self.assocSetProgress[8];
    assoc.a = self.assocSetProgress[9];
    
    assoc.b1 = self.assocSetProgress[10];
    assoc.b2 = self.assocSetProgress[11];
    assoc.b3 = self.assocSetProgress[12];
    assoc.b4 = self.assocSetProgress[13];
    assoc.b = self.assocSetProgress[14];
    
    assoc.c1 = self.assocSetProgress[15];
    assoc.c2 = self.assocSetProgress[16];
    assoc.c3 = self.assocSetProgress[17];
    assoc.c4 = self.assocSetProgress[18];
    assoc.c = self.assocSetProgress[19];
    
    assoc.d1 = self.assocSetProgress[20];
    assoc.d2 = self.assocSetProgress[21];
    assoc.d3 = self.assocSetProgress[22];
    assoc.d4 = self.assocSetProgress[23];
    assoc.d = self.assocSetProgress[24];
    
    assoc.id = self.assocSetProgress[25];

    BOOL saveResult = [self.context save:&error];
    
    if (!saveResult) {
        
        [NSException raise:@"Error Saving" format:@"Reason being: %@", [error localizedDescription]];
    } else{
        NSLog(@"Saved!");
    }
}

- (void)resetAssocProgress:(int)number{
    
    _assocSetProgress = [NSMutableArray arrayWithArray:@[@"ZGJIDHJA A", @"ZGJIDHJA B", @"ZGJIDHJA C", @"ZGJIDHJA D", @"ZGJIDHJA", @"A1", @"A2", @"A3", @"A4",@"ZGJIDHJA A", @"B1", @"B2", @"B3", @"B4",@"ZGJIDHJA B", @"C1", @"C2", @"C3", @"C4", @"ZGJIDHJA C", @"D1", @"D2", @"D3", @"D4", @"ZGJIDHJA D", [NSNumber numberWithInt:number]]];
    
    [self insertLoadAssocProgress:_assocSetProgress indexNumber:number];
}

- (void)revealSet:(int)number{
    
    _assocSetProgress = [NSMutableArray arrayWithArray:_assocSet];
    
    [self insertLoadAssocProgress:_assocSetProgress indexNumber:number];
}

@end
