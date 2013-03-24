/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
  
   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 
   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

#import "AWSSBJsonTokeniser.h"
#import "AWSSBJsonStreamParser.h"

@interface AWSSBJsonStreamParserState : NSObject
+ (id)sharedInstance;
- (BOOL)parser:(AWSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token;
- (AWSSBJsonStreamParserStatus)parserShouldReturn:(AWSSBJsonStreamParser*)parser;
- (void)parser:(AWSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok;
- (BOOL)needKey;

- (NSString*)name;

@end

@interface AWSSBJsonStreamParserStateStart : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateComplete : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateError : AWSSBJsonStreamParserState
@end


@interface AWSSBJsonStreamParserStateObjectStart : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateObjectGotKey : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateObjectSeparator : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateObjectGotValue : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateObjectNeedKey : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateArrayStart : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateArrayGotValue : AWSSBJsonStreamParserState
@end

@interface AWSSBJsonStreamParserStateArrayNeedValue : AWSSBJsonStreamParserState
@end
