//
//  Student.h
//  UI-17 SandBox
//
//  Created by dlios on 15-6-4.
//  Copyright (c) 2015年 周家稳. All rights reserved.
//

#import <Foundation/Foundation.h>

//#warning 归档第一步：签订NSCoding协议

@interface Student : NSObject<NSCoding>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, assign) NSInteger age;

@end
/*
 Student *stu = [[Student alloc] init];
 stu.name = @"张三";
 stu.sex = @"女";
 stu.age = 18;
 
 NSString *stuPath = [documentPath stringByAppendingPathComponent:@"student.av"];
 BOOL result3 = [NSKeyedArchiver archiveRootObject:stu toFile:stuPath];
 if (result3 == YES) {
 NSLog(@"类的==== 存入成功");
 }
 else
 {
 NSLog(@"类的==== 存入失败");
 }
 Student *stu1 = [NSKeyedUnarchiver unarchiveObjectWithFile:stuPath];
 NSLog(@"name=%@ sex=%@  age=%ld", stu1.name, stu1.sex, stu1.age);
 
 
 如果将存在多个对象的数组归档,那么对象应该遵循遵循NSCoding协议，并实现相关的方法
 
 
 
 
 
 
 */
