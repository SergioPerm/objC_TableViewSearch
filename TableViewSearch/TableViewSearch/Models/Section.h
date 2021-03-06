//
//  Section.h
//  TableViewSearch
//
//  Created by kluv on 25/03/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Section : NSObject

@property (strong, nonatomic) NSString* sectionName;
@property (assign, nonatomic) int indexSectionForDate;
@property (strong, nonatomic) NSMutableArray* studentsArr;

@end

NS_ASSUME_NONNULL_END
