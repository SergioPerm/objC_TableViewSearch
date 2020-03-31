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
#import "StudentCell.h"
#import "Student.h"

typedef enum {
    nameSectionType        = 1,
    lastNameSectionType    = 2,
    monthBirthSectionType  = 3
} StudentSectionType;

@interface ViewController ()

@property (strong, nonatomic) NSArray* namesArr;
@property (strong, nonatomic) NSMutableArray* sectionsArray;

@property (strong, nonatomic) NSOperation* currentOperation;
@property (strong, nonatomic) NSOperationQueue* queue;

@property (strong, nonatomic) NSMutableArray* studentsArray;

@property (assign, nonatomic) int currentSectionType;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
        
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.tableSearchBar.delegate = self;
    self.tableView.tableHeaderView = self.tableSearchBar;
    
    self.studentsArray = [[NSMutableArray alloc] init];
    
    NSDictionary* testNames = [self JSONFromFile];
    
    for (NSDictionary* nameDict in testNames) {
        
        NSString* fullName = [nameDict objectForKey:@"name"];
        
        NSArray* fullNameArr = [fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        Student* student = [[Student alloc] init];
        student.firstName = [fullNameArr objectAtIndex:1];
        student.lastName = [fullNameArr objectAtIndex:0];
        
        NSUInteger rndValue = 5 + arc4random() % ((365*25) - 5);
        
        student.birthDate = [self generateRandomDateWithinDaysBeforeSpecDay:rndValue];
        student.birthMonth = [self getMonthAsIntFromDate:student.birthDate];
        student.strBirthMonth = [self getMonthAsStringFromDate:student.birthDate];
        
        [self.studentsArray addObject:student];
        
    }
              
//    [self.studentsArray sortUsingDescriptors:@[
//        [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
//        [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
//        [NSSortDescriptor sortDescriptorWithKey:@"birthDate" ascending:YES]
//    ]];
    
    self.currentSectionType = nameSectionType;
    [self generateSectionsInBackgroundFromArray:self.studentsArray withFilter:self.tableSearchBar.text withSectionType:monthBirthSectionType];
    
}

#pragma mark - Methods

- (NSDate *)generateRandomDateWithinDaysBeforeSpecDay:(NSUInteger)daysBack {
    
    NSUInteger day = arc4random_uniform((u_int32_t)daysBack);  // explisit cast
    NSUInteger hour = arc4random_uniform(23);
    NSUInteger minute = arc4random_uniform(59);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:31];
    [comps setMonth:12];
    [comps setYear:2010];
    NSDate *dateTo = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *offsetComponents = [NSDateComponents new];
    [offsetComponents setDay:(day * -1)];
    [offsetComponents setHour:hour];
    [offsetComponents setMinute:minute];
    
    NSDate *randomDate = [gregorian dateByAddingComponents:offsetComponents
                                                    toDate:dateTo
                                                   options:0];
    
    return randomDate;
    
}

- (NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"datanames" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void) generateSectionsInBackgroundFromArray:(NSArray*) array withFilter:(NSString*) filter withSectionType:(StudentSectionType) sectionType {
    
    self.queue = [NSOperationQueue new];
    
    [self.currentOperation cancel];
    
    __weak ViewController* weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray* sectionsArray = [[NSMutableArray alloc] initWithArray:[weakSelf generateSectionsFromArray:array withFilter:filter withSectionType:sectionType]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sectionsArray = sectionsArray;
            [weakSelf.tableView reloadData];
            
            self.currentOperation = nil;
        });
        
    }];
    
    [self.queue addOperation:self.currentOperation];
    
    //[self.currentOperation start];
    
}

- (NSArray*) generateSectionsFromArray:(NSArray*) array withFilter:(NSString*) filter withSectionType:(StudentSectionType) sectionType {
    
    [self sortMainStudentsArrBySectionType:sectionType];
    
    NSString* currentSectionName= nil;
    NSString* sectionName = nil;
    Section* currentSection = nil;
    
    NSMutableArray* sectionsArray = [[NSMutableArray alloc] init];
    
    for (Student* student in array) {
        
        if (![filter isEqualToString:@""]) {
            if ([student.firstName rangeOfString:filter].location == NSNotFound && [student.lastName rangeOfString:filter].location == NSNotFound) {
                continue;
            }
        }
        
        if (sectionType == nameSectionType) {
            sectionName = [student.firstName substringToIndex:1];
        } else if (sectionType == lastNameSectionType) {
            sectionName = [student.lastName substringToIndex:1];
        } else if (sectionType == monthBirthSectionType) {
            sectionName = student.strBirthMonth;
        }
        
        if (![currentSectionName isEqualToString:sectionName]) {
            
            if (currentSection)
                [sectionsArray addObject:currentSection];
            
            Section* newSection = [[Section alloc] init];
            newSection.sectionName = sectionName;
            
            if (sectionType == monthBirthSectionType) {
                newSection.indexSectionForDate = student.birthMonth;
            }
            
            [newSection.studentsArr addObject:student];
            
            currentSection = newSection;
            
        } else {
            
            [currentSection.studentsArr addObject:student];
            
        }
        
        currentSectionName = sectionName;
        
    }
    
    if (currentSection)
        [sectionsArray addObject:currentSection];
    
    return sectionsArray;
    
}

- (void) sortMainStudentsArrBySectionType:(StudentSectionType) sectionType {
    
    if (sectionType == monthBirthSectionType) {
        
        [self.studentsArray sortUsingDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"birthMonth" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]
        ]];
        
    } else if (sectionType == nameSectionType) {
        
        [self.studentsArray sortUsingDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"birthDate" ascending:YES]
        ]];
        
    } else if (sectionType == lastNameSectionType) {
        
        [self.studentsArray sortUsingDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"birthDate" ascending:YES]
        ]];
        
    }
    
}

- (NSString*) getMonthAsStringFromDate:(NSDate*) birthDate {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    [df setDateFormat:@"MMMM"];
    NSString* myMonthString = [df stringFromDate:birthDate];
    
    return myMonthString;
    
}

- (int) getMonthAsIntFromDate:(NSDate*) birthDate {
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:birthDate];
    
    int month = (int)[components month]; //gives you month
    
    return month;
    
}

#pragma mark - UITableViewSource

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray* indexArr = [NSMutableArray array];
    
    for (Section* letterSection in self.sectionsArray) {
        if (self.currentSectionType == monthBirthSectionType) {
            [indexArr addObject:[NSString stringWithFormat:@"%d", letterSection.indexSectionForDate]];
        } else {
            [indexArr addObject:[letterSection.sectionName substringToIndex:1]];
        }
    }
    
    return indexArr;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.sectionsArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Section* currentSection = [self.sectionsArray objectAtIndex:section];
    
    return [currentSection.studentsArr count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    Section* currentSection = [self.sectionsArray objectAtIndex:section];
    
    return currentSection.sectionName;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"studentIdentifier";
    
    StudentCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
        
    Section* currentSection = [self.sectionsArray objectAtIndex:indexPath.section];
    Student* student = [currentSection.studentsArr objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    cell.birthLabel.text = [formatter stringFromDate:student.birthDate];
    
    return cell;
    
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.f;
    
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
    
    [self generateSectionsInBackgroundFromArray:self.studentsArray withFilter:self.tableSearchBar.text withSectionType:self.currentSectionType];
    [self.tableView reloadData];
    
}


#pragma mark - Actions

- (IBAction)sectionsChangeAction:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.currentSectionType = nameSectionType;
    } else if (sender.selectedSegmentIndex == 1) {
        self.currentSectionType = lastNameSectionType;
    } else if (sender.selectedSegmentIndex == 2) {
        self.currentSectionType = monthBirthSectionType;
    }
    
    [self generateSectionsInBackgroundFromArray:self.studentsArray withFilter:self.tableSearchBar.text withSectionType:self.currentSectionType];
    [self.tableView reloadData];
    
}
@end
