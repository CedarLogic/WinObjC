//******************************************************************************
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#include "Starboard.h"
#include "Foundation/NSError.h"
#include "Foundation/NSString.h"

#include <time.h>

@implementation NSError {
    idretaintype(NSString) _domain;
    idretaintype(NSDictionary) _userInfo;
    int      _code;
    idretaintype(NSString) _description;
}
    +(instancetype) errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
        NSError* ret = [self alloc];
        ret = [ret initWithDomain:domain code:code userInfo:dict];

        return [ret autorelease];
    }

    -(instancetype) initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
        _domain.attach([domain copy]);
        _code = code;

        const char *err = [domain UTF8String];

        EbrDebugLog("failure %s: %d\n", err, code);

        _userInfo = dict;

        id values = [dict allValues];
        id keys = [dict allKeys];

        DWORD count = [dict count];

        for ( int i = 0; i < count; i ++ ) {
            const char *pVal = [[[values objectAtIndex:i] description] UTF8String];
            const char *pKey = [[[keys objectAtIndex:i] description] UTF8String];

            EbrDebugLog("%d: Key=%s Val=%s\n", i, pVal, pKey);
        }

        return self;
    }

    -(NSString *) domain {
        return _domain;
    }

    -(int) code {
        return _code;
    }

    -(NSDictionary *) userInfo {
        return _userInfo;
    }

    -(NSString *) localizedDescription {
        id ret;

        if ( (ret = [_userInfo objectForKey:@"NSLocalizedDescriptionKey"]) != nil ) {
            return ret;
        }

        if ( _description ) return _description;
        return @"Generic error";
    }

    -(NSString *) localizedFailureReason {
        id ret;

        if ( (ret = [_userInfo objectForKey:@"NSLocalizedFailureReasonErrorKey"]) != nil ) {
            return ret;
        }

        return @"Generic failure";
    }

    -(NSString *) description {
        return [self localizedDescription];
    }

    -(void) _setDescription:(id)description {
        _description.attach([description copy]);
    }

    -(instancetype) copyWithZone: (NSZone *) zone {
        return [self retain];
    }

    -(void) dealloc {
        _domain = nil;
        _userInfo = nil;
        _description = nil;
        [super dealloc];
    }
@end

