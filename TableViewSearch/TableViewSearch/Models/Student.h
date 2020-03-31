//
//  Student.h
//  TableViewSearch
//
//  Created by kluv on 27/03/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSDate* birthDate;
@property (assign, nonatomic) int birthMonth;
@property (strong, nonatomic) NSString* strBirthMonth;

@end

NS_ASSUME_NONNULL_END
