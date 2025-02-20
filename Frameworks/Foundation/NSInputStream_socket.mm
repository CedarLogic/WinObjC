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
#include "Foundation/NSStream.h"
#include "NSInputStream_socket.h"
#include "NSSelectInputSource.h"
#include "NSSSLHandler.h"

@implementation NSInputStream_socket : NSStream
    /* annotate with type */ -(id) initWithSocket:(id)socket streamStatus:(DWORD)status {
        _delegate=self;
        _error=nil;
        _status=status;
        _socket=[socket retain];
        _inputSource=nil;
        return self;
    }

    /* annotate with type */ -(void) setDelegate:(id)delegate {
        _delegate=delegate;
        if(_delegate==nil)
            _delegate=self;
    }

    /* annotate with type */ -(id) open {
        if(_status==NSStreamStatusNotOpen){
            _status=NSStreamStatusOpening;
        }
        return self;
    }

    /* annotate with type */ -(id) close {
        [_socket close];
        return self;
    }

    /* annotate with type */ -(id) scheduleInRunLoop:(id)runLoop forMode:(id)mode {
        if(_inputSource==nil) {
            _inputSource=[[NSSelectInputSource alloc] initWithSocket:_socket];
            [_inputSource setDelegate:self];
            [_inputSource setSelectEventMask:NSSelectReadEvent | NSSelectExceptEvent];
        }

        [runLoop addInputSource:_inputSource forMode:mode];

        return self;
    }

    /* annotate with type */ -(id) removeFromRunLoop:(id)runLoop forMode:(id)mode {
        if(_inputSource!=nil)
            [runLoop removeInputSource:_inputSource forMode:mode];

        return self;
    }

    /* annotate with type */ -(id) selectInputSource:(id)inputSource selectEvent:(DWORD)selectEvent {
        NSStreamEvent event;

        if ( selectEvent == NSSelectReadEvent ) {
            switch(_status) {
                case NSStreamStatusOpening:
                    _status=NSStreamStatusOpen;
                    event=NSStreamEventOpenCompleted;
                    break;

                case NSStreamStatusOpen: {
                    id sslHandler = [_socket sslHandler];

                    if (sslHandler != nil) {
                        [sslHandler runHandshakeIfNeeded:_socket];
                    }

                    if ([self hasBytesAvailable])
                        event=NSStreamEventHasBytesAvailable;
                    else
                        event=NSStreamEventNone;
                }
                    break;

                case NSStreamStatusAtEnd:
                    event=NSStreamEventEndEncountered;
                    break;

                default:
                    event=NSStreamEventNone;
                    break;
            }
        } else if ( selectEvent == NSSelectExceptEvent ) {
            event=NSStreamEventErrorOccurred;
        }  else {
            assert(0);
        }

        if(event!=NSStreamEventNone && [_delegate respondsToSelector:@selector(stream:handleEvent:)])
            [_delegate stream:self handleEvent:event];

        return self;
    }

    -(int) read:(uint8_t *)buffer maxLength:(DWORD)maxLength {
        NSInteger result;
   
        if(_status==NSStreamStatusAtEnd)
            return 0;
    
        if(_status!=NSStreamStatusOpen && _status!=NSStreamStatusOpening)
            return -1;
  
        NSSSLHandler* sslHandler = [_socket sslHandler];
   
        if(sslHandler==nil)
            result = [_socket read:buffer maxLength:maxLength];
        else {
            [sslHandler runWithSocket:_socket];

            result = [sslHandler readPlaintext:buffer maxLength:maxLength];
            EbrDebugLog("Read %d result bytes\n", result);

            //[sslHandler runWithSocket:_socket];
        }
      
        if(result==0)
            _status=NSStreamStatusAtEnd;
        if(result==-1)
            _status=NSStreamStatusError;
    
        return result;
    }

    -(BOOL) hasBytesAvailable {
        BOOL result=NO;
   
        if(_status==NSStreamStatusOpen){
            id sslHandler = [_socket sslHandler];
    
            if(sslHandler==nil)
                result = [_socket hasBytesAvailable];
            else {
                if ([_socket hasBytesAvailable])
                    if ([sslHandler transferOneBufferFromSocketToSSL:_socket] <=0){
                        // If the read failed we want to return YES so that the end of stream can be read
                        return YES;
                    }
      
                result = ([sslHandler readBytesAvailable] >0)?YES:NO;
            }
        }
   
        return result;
    }

    /* annotate with type */ -(id) setProperty:(id)prop forKey:(id)key {
        if ( [key isEqualToString:(NSString*) kCFStreamPropertySSLSettings])
            return [_socket setSSLProperties:prop];

        assert(0);
        return NO;
    }

    -(void) dealloc {
        [_inputSource setDelegate:nil];
   
        [super dealloc];
    }

    
@end

