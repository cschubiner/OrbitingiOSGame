/*
 * JS Bindings: https://github.com/zynga/jsbindings
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "js_bindings_config.h"

#ifdef JSB_INCLUDE_COCOSBUILDERREADER

#import "js_bindings_core.h"
#import "js_bindings_CocosBuilderReader_classes.h"
#import "js_bindings_basic_conversions.h"

@interface CCBReaderForwarder : NSObject
{
	JSObject *_jsthis;
	JSContext *_cx;
}

-(id) initWithJSObject:(JSObject*)jsowner context:(JSContext*)cx;
-(NSString*) convertToJSName:(NSString*)nativeName;
@end

@implementation CCBReaderForwarder

-(id) initWithJSObject:(JSObject*)jsowner context:(JSContext*)cx;
{
	if( (self=[super init])) {

		_jsthis = jsowner;
		_cx = cx;
	}
	
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"deallocing %@", self);
	[super dealloc];
}

-(NSString*) convertToJSName:(NSString*)nativeName
{
	return [nativeName stringByReplacingOccurrencesOfString:@":" withString:@""];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	// void, self, _cmd, sender
	return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}

- (void)forwardInvocation:(NSInvocation *)inv
{
	NSString *name = NSStringFromSelector([inv selector] );

	CCLOGINFO(@"Calling JS function: %@", name);
	
	JSBool found;
	const char *functionName = [[self convertToJSName:name] UTF8String];

	JS_HasProperty(_cx, _jsthis, functionName, &found);
	if (found == JS_TRUE) {
		jsval rval, fval;
		jsval *argv = NULL;
		unsigned argc=0;
		
		JS_GetProperty(_cx, _jsthis, functionName, &fval);
		JS_CallFunctionValue(_cx, _jsthis, fval, argc, argv, &rval);
	}
}
@end

// Arguments: NSString*, NSObject*
// Ret value: CCNode* (o)
JSBool JSB_CCBReader_nodeGraphFromFile_owner_parentSize__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >= 1 && argc<=3 , "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString* arg0; JSObject *arg1; CGSize arg2;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &arg0 );
	if( argc >= 2 )
		ok &= JS_ValueToObject(cx, *argvp++, &arg1 );
	if( argc >= 3 )
		ok &= jsval_to_CGSize(cx, *argvp++, &arg2 );
	
	if( ! ok ) return JS_FALSE;
	

	CCNode* ret_val;
	
	if( argc == 1 )
		ret_val = [CCBReader nodeGraphFromFile:(NSString*)arg0];
	else if(argc == 2 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader nodeGraphFromFile:arg0 owner:owner];

		// XXX LEAK
		[owner retain];
	}
	else if(argc == 3 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader nodeGraphFromFile:arg0 owner:owner parentSize:arg2];
		
		// XXX LEAK
		[owner retain];
	}

	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

// Arguments: NSString*, NSObject*, CGSize
// Ret value: CCScene* (o)
JSBool JSB_CCBReader_sceneWithNodeGraphFromFile_owner_parentSize__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >= 1 && argc<=3 , "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString* arg0; JSObject *arg1; CGSize arg2;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &arg0 );
	if( argc >= 2 )
		ok &= JS_ValueToObject(cx, *argvp++, &arg1 );
	if( argc >= 3 )
		ok &= jsval_to_CGSize(cx, *argvp++, &arg2 );

	if( ! ok ) return JS_FALSE;
	
	CCScene* ret_val;
	
	if( argc == 1 )
		ret_val = [CCBReader sceneWithNodeGraphFromFile:(NSString*)arg0];
	else if( argc == 2 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader sceneWithNodeGraphFromFile:arg0 owner:owner];
		
		// XXX LEAK
		[owner retain];
	}
	else if( argc == 3 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader sceneWithNodeGraphFromFile:arg0 owner:owner parentSize:arg2];
		
		// XXX LEAK
		[owner retain];
	}

	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

#endif // JSB_INCLUDE_COCOSBUILDERREADER

