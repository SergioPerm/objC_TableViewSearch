//
//  Section.m
//  TableViewSearch
//
//  Created by kluv on 25/03/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "Section.h"

@implementation Section

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.studentsArr = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
