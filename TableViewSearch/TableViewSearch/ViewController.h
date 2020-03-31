//
//  ViewController.h
//  TableViewSearch
//
//  Created by kluv on 24/03/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *tableSearchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sectionsSegmentCtrl;

- (IBAction)sectionsChangeAction:(UISegmentedControl*)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sectionsSegmentedCtrl;


@end

