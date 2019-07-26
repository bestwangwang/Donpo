//
//  DetailViewController.h
//  Donpo
//
//  Created by benwang on 2019/7/26.
//  Copyright © 2019 benco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

