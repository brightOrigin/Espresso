//
// Created by Tony on 10/21/13.
//


@interface BOCDImportOperation : NSOperation

@property (nonatomic, strong) NSManagedObjectContext* context;
@property (nonatomic, strong) NSDictionary *operationDataDictionary;
@property (nonatomic, strong) NSArray *operationDataArray;

- (id) initWithImportDataDictionary:(NSDictionary *)dataDictionary;
- (id) initWithImportDataArray:(NSArray *)dataArray;

@end