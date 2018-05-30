//
//  Student.m
//  UI-17 SandBox
//
//  Created by dlios on 15-6-4.
//  Copyright (c) 2015年 周家稳. All rights reserved.
//

#import "Student.h"

@implementation Student

//#warning 归档第二步：实现编码方法，进行编码
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeInteger:self.age forKey:@"age"];
    
    
    
}
//#warning 归档第三步：对student类进行编码
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.age = [aDecoder decodeIntegerForKey:@"age"];
        
    }
    return self;
}






















@end
