/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef _NSMUTABLEDICTIONARY_H_
#define _NSMUTABLEDICTIONARY_H_

#import <Foundation/NSDictionary.h>

FOUNDATION_EXPORT_CLASS
@interface NSMutableDictionary : NSDictionary

- initWithCapacity:(NSUInteger)capacity;

+ dictionaryWithCapacity:(NSUInteger)capacity;

- (void)setObject:object forKey:key;
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;
- (void)setDictionary:(NSDictionary *)dictionary;

- (void)removeObjectForKey:key;
- (void)removeAllObjects;
- (void)removeObjectsForKeys:(NSArray *)keys;

- (void) setObject:(id)obj forKeyedSubscript:(id)key;

@end

#endif /* _NSMUTABLEDICTIONARY_H_ */