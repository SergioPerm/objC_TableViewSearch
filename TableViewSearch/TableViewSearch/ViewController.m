//
//  ViewController.m
//  TableViewSearch
//
//  Created by kluv on 24/03/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Random.h"
#import "Section.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray* namesArr;
@property (strong, nonatomic) NSMutableArray* sectionsArray;

@property (strong, nonatomic) NSOperation* currentOperation;
@property (strong, nonatomic) NSOperationQueue* queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.namesArr = @[@"aaa", @"bbb", @"ccc"];
    
    NSMutableArray* array = [NSMutableArray array];
    
    for (int i = 0; i < 200000; i++) {
        [array addObject:[[NSString randomAlphanumericString] capitalizedString]];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    [array sortUsingDescriptors:@[sortDescriptor]];
    
    self.namesArr = array;
    //self.sectionsArray = [[NSMutableArray alloc] initWithArray:[self generateSectionsFromArray:self.namesArr withFilter:self.tableSearchBar.text]];
    
    [self generateSectionsInBackgroundFromArray:self.namesArr withFilter:self.tableSearchBar.text];
    
}

#pragma mark - Methods

- (void) generateSectionsInBackgroundFromArray:(NSArray*) array withFilter:(NSString*) filter {
    
    self.queue = [NSOperationQueue new];
    
    [self.currentOperation cancel];
    
    __weak ViewController* weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray* sectionsArray = [[NSMutableArray alloc] initWithArray:[weakSelf generateSectionsFromArray:array withFilter:filter]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sectionsArray = sectionsArray;
            [weakSelf.tableView reloadData];
            
            self.currentOperation = nil;
        });
        
    }];
    
    [self.queue addOperation:self.currentOperation];
    
    //[self.currentOperation start];
    
}

- (NSArray*) generateSectionsFromArray:(NSArray*) array withFilter:(NSString*) filter {
    
    NSString* currentLetter = nil;
    Section* currentSection = nil;
    
    NSMutableArray* sectionsArray = [[NSMutableArray alloc] init];
    
    for (NSString* string in array) {
        
        if (![filter isEqualToString:@""]) {
            if ([string rangeOfString:filter].location == NSNotFound) {
                continue;
            }
        }
        
        NSString* firstLetter = [string substringToIndex:1];
        
        if (![currentLetter isEqualToString:firstLetter]) {
            
            if (currentSection)
                [sectionsArray addObject:currentSection];
            
            Section* letterSection = [[Section alloc] init];
            letterSection.sectionName = firstLetter;
            [letterSection.nameArr addObject:string];
            
            currentSection = letterSection;
            
        } else {
            
            [currentSection.nameArr addObject:string];
            
        }
        
        currentLetter = firstLetter;
        
    }
    
    if (currentSection)
        [sectionsArray addObject:currentSection];
    
    return sectionsArray;
    
}

#pragma mark - UITableViewSource

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray* indexArr = [NSMutableArray array];
    
    for (Section* letterSection in self.sectionsArray) {
        [indexArr addObject:letterSection.sectionName];
    }
    
    return indexArr;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.sectionsArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Section* currentSection = [self.sectionsArray objectAtIndex:section];
    
    return [currentSection.nameArr count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    Section* currentSection = [self.sectionsArray objectAtIndex:section];
    
    return currentSection.sectionName;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    Section* currentSection = [self.sectionsArray objectAtIndex:indexPath.section];
    NSString* name = [currentSection.nameArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = name;
    
    return cell;
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self generateSectionsInBackgroundFromArray:self.namesArr withFilter:self.tableSearchBar.text];
    [self.tableView reloadData];
    
}

@end
