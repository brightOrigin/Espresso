//
// Created by Tony on 10/21/13.
//

/**
* NSOperation subclass that provides background processing of updates from server.
*/

@interface BOCDImportOperation : NSOperation

@property (nonatomic, strong) NSManagedObjectContext* context;
@property (nonatomic, strong) NSDictionary *operationDataDictionary;
@property (nonatomic, strong) NSArray *operationDataArray;

- (id) initWithImportDataDictionary:(NSDictionary *)dataDictionary;
- (id) initWithImportDataArray:(NSArray *)dataArray;

@end